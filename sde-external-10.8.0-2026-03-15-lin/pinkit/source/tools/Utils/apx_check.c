/*
 * Copyright (C) 2025-2025 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#include <stdio.h>

int SupportsApx();

int main()
{
    if (SupportsApx())
        printf("Yes\n");
    else
        printf("No\n");
    return 0;
}
