#ifndef _OCCLUM_ENTRY_H
#define _OCCLUM_ENTRY_H

extern void *__occlum_entry;
#define IS_RUNNING_ON_OCCLUM      (__occlum_entry != 0)

#endif /* _OCCLUM_ENTRY_H */
