/* IBM_PROLOG_BEGIN_TAG                                                   */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* $Source: src/kv/tag.c $                                                */
/*                                                                        */
/* IBM Data Engine for NoSQL - Power Systems Edition User Library Project */
/*                                                                        */
/* Contributors Listed Below - COPYRIGHT 2014,2015                        */
/* [+] International Business Machines Corp.                              */
/*                                                                        */
/*                                                                        */
/* Licensed under the Apache License, Version 2.0 (the "License");        */
/* you may not use this file except in compliance with the License.       */
/* You may obtain a copy of the License at                                */
/*                                                                        */
/*     http://www.apache.org/licenses/LICENSE-2.0                         */
/*                                                                        */
/* Unless required by applicable law or agreed to in writing, software    */
/* distributed under the License is distributed on an "AS IS" BASIS,      */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or        */
/* implied. See the License for the specific language governing           */
/* permissions and limitations under the License.                         */
/*                                                                        */
/* IBM_PROLOG_END_TAG                                                     */

#include <stdio.h>
#include "tag.h"
#include "am.h"
#include <arkdb_trace.h>
#include <errno.h>

tags_t* tag_new(uint32_t n)
{
  int i;
  tags_t *tags = am_malloc(sizeof(tags_t) + n * sizeof(int32_t));

  tags->n = n;
  tags->c = n;
  pthread_mutex_init(&(tags->l), NULL);
  for(i=0; i<n; i++) {tags->s[i] = i;}

  KV_TRC_EXT3(pAT, "NEWTAG  tags:%p n:%d", tags, tags->c);
  return tags;
}

void tag_free(tags_t *tags)
{
  pthread_mutex_destroy(&(tags->l));
  am_free(tags);
  return;
}

int tag_unbury(tags_t *tags, int32_t *tag)
{
  int ret = 0;

  pthread_mutex_lock(&(tags->l));
  if (tags->c==0) {ret = EAGAIN;}
  else            {*tag = tags->s[--(tags->c)];}
  pthread_mutex_unlock(&(tags->l));

  KV_TRC_EXT3(pAT, "GETTAG  tags:%p c:%d tag:%d ret:%d", tags,tags->c,*tag,ret);
  return ret;
}

int tag_bury(tags_t *tags, int32_t tag)
{
  int ret = 0;

  pthread_mutex_lock(&(tags->l));
  if (tags->c == tags->n) {ret = ENOSPC;}
  else                    {tags->s[tags->c++] = tag;}
  pthread_mutex_unlock(&(tags->l));

  KV_TRC_EXT3(pAT, "PUTTAG  tags:%p c:%d tag:%d ret:%d", tags, tags->c,tag,ret);
  return ret;
}
