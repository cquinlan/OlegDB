#pragma once
/* Utility functions that don't have a home. */

/* Internal function used to get the last bucket on the
 * linked list of ol_bucket objects in a db slot. */
ol_bucket *_ol_get_last_bucket_in_slot(ol_bucket *bucket);

/* Internal function used to free a bucket's memory. */
void _ol_free_bucket(ol_bucket **ptr);

/* Internal function used to find a buckets position in the DB */
int _ol_calc_idx(const size_t ht_size, const uint32_t hash);
