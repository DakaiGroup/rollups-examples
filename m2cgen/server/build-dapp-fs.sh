#!/bin/bash
# Copyright 2022 Cartesi Pte. Ltd.
#
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

DAPP_FS=/opt/cartesi/m2cgen-dapp-fs/m2cgen-dapp
DAPP_FS_TAR=/opt/cartesi/m2cgen-dapp-fs/m2cgen-dapp.tar
DAPP_FS_BIN=/opt/cartesi/m2cgen-dapp-fs/m2cgen-dapp.ext2

mkdir -p $DAPP_FS
cp ./m2cgen.py $DAPP_FS
cp ./model.py $DAPP_FS
(cd $DAPP_FS; tar --sort=name --mtime="2022-01-01" --owner=0 --group=0 --numeric-owner -cf $DAPP_FS_TAR m2cgen.py model.py)
genext2fs -f -i 512 -b 1024 -a $DAPP_FS_TAR $DAPP_FS_BIN
truncate -s %4096 $DAPP_FS_BIN
