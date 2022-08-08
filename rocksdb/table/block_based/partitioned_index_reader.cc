//  Copyright (c) 2011-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under both the GPLv2 (found in the
//  COPYING file in the root directory) and Apache 2.0 License
//  (found in the LICENSE.Apache file in the root directory).
//
// Copyright (c) 2011 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.
#include "table/block_based/partitioned_index_reader.h"

#include "file/random_access_file_reader.h"
#include "table/block_based/block_based_table_reader.h"
#include "table/block_based/partitioned_index_iterator.h"

extern int NUM_THREADS;

namespace ROCKSDB_NAMESPACE {
Status PartitionIndexReader::Create(
    const BlockBasedTable* table, const ReadOptions& ro,
    FilePrefetchBuffer* prefetch_buffer, bool use_cache, bool prefetch,
    bool pin, BlockCacheLookupContext* lookup_context,
    std::unique_ptr<IndexReader>* index_reader) {
  assert(table != nullptr);
  assert(table->get_rep());
  assert(!pin || prefetch);
  assert(index_reader != nullptr);

  CachableEntry<Block> index_block;
  if (prefetch || !use_cache) {
    const Status s =
        ReadIndexBlock(table, prefetch_buffer, ro, use_cache,
                       /*get_context=*/nullptr, lookup_context, &index_block);
    if (!s.ok()) {
      return s;
    }

    if (use_cache && !pin) {
      index_block.Reset();
    }
  }

  index_reader->reset(new PartitionIndexReader(table, std::move(index_block)));

  return Status::OK();
}

InternalIteratorBase<IndexValue>* PartitionIndexReader::NewIterator(
    const ReadOptions& read_options, bool /* disable_prefix_seek */,
    IndexBlockIter* iter, GetContext* get_context,
    BlockCacheLookupContext* lookup_context) {
  const bool no_io = (read_options.read_tier == kBlockCacheTier);
  CachableEntry<Block> index_block;
  printf("top level index\n");
  const Status s =
      GetOrReadIndexBlock(no_io, get_context, lookup_context, &index_block);
  if (!s.ok()) {
    if (iter != nullptr) {
      iter->Invalidate(s);
      return iter;
    }

    return NewErrorInternalIterator<IndexValue>(s);
  }

//  if(gettid()%NUM_THREADS==0){
//	  printf("index %p %ld\n",index_block.GetValue(), index_block.GetValue()->size());
//  }

  const BlockBasedTable::Rep* rep = table()->rep_;
  InternalIteratorBase<IndexValue>* it = nullptr;

  Statistics* kNullStats = nullptr;
  // Filters are already checked before seeking the index
  if (!partition_map_.empty()) {
    // We don't return pinned data from index blocks, so no need
    // to set `block_contents_pinned`.
    it = NewTwoLevelIterator(
        new BlockBasedTable::PartitionedIndexIteratorState(table(),
                                                           &partition_map_),
        index_block.GetValue()->NewIndexIterator(
            internal_comparator()->user_comparator(),
            rep->get_global_seqno(BlockType::kIndex), nullptr, kNullStats, true,
            index_has_first_key(), index_key_includes_seq(),
            index_value_is_full()));
  } else {
    ReadOptions ro;
    ro.fill_cache = read_options.fill_cache;
    ro.deadline = read_options.deadline;
    ro.io_timeout = read_options.io_timeout;
    ro.adaptive_readahead = read_options.adaptive_readahead;
    ro.async_io = read_options.async_io;

    // We don't return pinned data from index blocks, so no need
    // to set `block_contents_pinned`.
	size_t block_size = index_block.GetValue()->size();
	size_t filter_size = DecodeFixed64(&index_block.GetValue()->data()[block_size-8]);
	size_t index_size = block_size - filter_size - sizeof(uint64_t);
	printf("block %lu filter %lu index %lu\n", block_size, filter_size, index_size);
	
	std::unique_ptr<char[]> tmp_buf(new char[filter_size]);
	memcpy(tmp_buf.get(), index_block.GetValue()->data(), filter_size);
	
	BlockContents contents(std::move(tmp_buf), filter_size);
	Block tmp_block(std::move(contents));
    
	std::unique_ptr<InternalIteratorBase<IndexValue>> index_iter(
        tmp_block.NewIndexIterator(
            internal_comparator()->user_comparator(),
            rep->get_global_seqno(BlockType::kIndex), nullptr, kNullStats, true,
            index_has_first_key(), index_key_includes_seq(),
            index_value_is_full()));
/*
    std::unique_ptr<InternalIteratorBase<IndexValue>> index_iter(
        index_block.GetValue()->NewIndexIterator(
            internal_comparator()->user_comparator(),
            rep->get_global_seqno(BlockType::kIndex), nullptr, kNullStats, true,
            index_has_first_key(), index_key_includes_seq(),
            index_value_is_full()));
*/
    it = new PartitionedIndexIterator(
        table(), ro, *internal_comparator(), std::move(index_iter),
        lookup_context ? lookup_context->caller
                       : TableReaderCaller::kUncategorized);
  }

  assert(it != nullptr);
  index_block.TransferTo(it);

  return it;

  // TODO(myabandeh): Update TwoLevelIterator to be able to make use of
  // on-stack BlockIter while the state is on heap. Currentlly it assumes
  // the first level iter is always on heap and will attempt to delete it
  // in its destructor.
}
Status PartitionIndexReader::CacheDependencies(const ReadOptions& ro,
                                               bool pin) {
  // Before read partitions, prefetch them to avoid lots of IOs
  BlockCacheLookupContext lookup_context{TableReaderCaller::kPrefetch};
  const BlockBasedTable::Rep* rep = table()->rep_;
  IndexBlockIter biter;
  BlockHandle handle;
  Statistics* kNullStats = nullptr;

  CachableEntry<Block> index_block;
  {
    Status s = GetOrReadIndexBlock(false /* no_io */, nullptr /* get_context */,
                                   &lookup_context, &index_block);
    if (!s.ok()) {
      return s;
    }
  }

  // We don't return pinned data from index blocks, so no need
  // to set `block_contents_pinned`.
  size_t block_size = index_block.GetValue()->size();
  size_t filter_size = DecodeFixed64(&index_block.GetValue()->data()[block_size-8]);
  printf("block %lu filter %lu\n", block_size, filter_size);
  BlockContents contents = BlockContents(Slice(index_block.GetValue()->data(), filter_size));
  Block tmp_block = Block(std::move(contents));

  tmp_block.NewIndexIterator(
      internal_comparator()->user_comparator(),
      rep->get_global_seqno(BlockType::kIndex), &biter, kNullStats, true,
      index_has_first_key(), index_key_includes_seq(), index_value_is_full());

/*  index_block.GetValue()->NewIndexIterator(
      internal_comparator()->user_comparator(),
      rep->get_global_seqno(BlockType::kIndex), &biter, kNullStats, true,
      index_has_first_key(), index_key_includes_seq(), index_value_is_full());
*/
  // Index partitions are assumed to be consecuitive. Prefetch them all.
  // Read the first block offset
  biter.SeekToFirst();
  if (!biter.Valid()) {
    // Empty index.
    return biter.status();
  }
  handle = biter.value().handle;
  uint64_t prefetch_off = handle.offset();

  // Read the last block's offset
  biter.SeekToLast();
  if (!biter.Valid()) {
    // Empty index.
    return biter.status();
  }
  handle = biter.value().handle;
  uint64_t last_off =
      handle.offset() + BlockBasedTable::BlockSizeWithTrailer(handle);
  uint64_t prefetch_len = last_off - prefetch_off;
  std::unique_ptr<FilePrefetchBuffer> prefetch_buffer;
  rep->CreateFilePrefetchBuffer(0, 0, &prefetch_buffer,
                                false /*Implicit auto readahead*/,
                                false /*async_io*/);
  IOOptions opts;
  {
    Status s = rep->file->PrepareIOOptions(ro, opts);
    if (s.ok()) {
      s = prefetch_buffer->Prefetch(opts, rep->file.get(), prefetch_off,
                                    static_cast<size_t>(prefetch_len),
                                    ro.rate_limiter_priority);
    }
    if (!s.ok()) {
      return s;
    }
  }

  // For saving "all or nothing" to partition_map_
  UnorderedMap<uint64_t, CachableEntry<Block>> map_in_progress;

  // After prefetch, read the partitions one by one
  biter.SeekToFirst();
  size_t partition_count = 0;
  for (; biter.Valid(); biter.Next()) {
    handle = biter.value().handle;
    CachableEntry<Block> block;
    ++partition_count;
    // TODO: Support counter batch update for partitioned index and
    // filter blocks
    Status s = table()->MaybeReadBlockAndLoadToCache(
        prefetch_buffer.get(), ro, handle, UncompressionDict::GetEmptyDict(),
        /*wait=*/true, /*for_compaction=*/false, &block, BlockType::kIndex,
        /*get_context=*/nullptr, &lookup_context, /*contents=*/nullptr);

    if (!s.ok()) {
      return s;
    }
    if (block.GetValue() != nullptr) {
      // Might need to "pin" some mmap-read blocks (GetOwnValue) if some
      // partitions are successfully compressed (cached) and some are not
      // compressed (mmap eligible)
      if (block.IsCached() || block.GetOwnValue()) {
        if (pin) {
          map_in_progress[handle.offset()] = std::move(block);
        }
      }
    }
  }
  Status s = biter.status();
  // Save (pin) them only if everything checks out
  if (map_in_progress.size() == partition_count && s.ok()) {
    std::swap(partition_map_, map_in_progress);
  }
  return s;
}

}  // namespace ROCKSDB_NAMESPACE
