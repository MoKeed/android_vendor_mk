# Copyright (C) 2015 The MoKee Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Rules for running apicheck to confirm that you haven't broken
# api compatibility or added apis illegally.
#

# skip api check for PDK buid
ifeq (,$(filter true, $(WITHOUT_CHECK_API) $(TARGET_BUILD_PDK) $(TARGET_DISABLE_MKSDK)))

.PHONY: checkapi-mk

# Run the checkapi rules by default.
droidcore: checkapi-mk

# Validate against previous release platform sdk version api text within prebuilts
mk_last_released_sdk_version := $(MK_PLATFORM_SDK_VERSION)

.PHONY: check-mk-public-api
checkapi-mk : check-mk-public-api

.PHONY: update-mk-api

# INTERNAL_MK_PLATFORM_API_FILE is the one build by droiddoc.
# Note that since INTERNAL_MK_PLATFORM_API_FILE  is the byproduct of api-stubs module,
# (See vendor/mksdk/Android.mk)
# we need to add api-stubs as additional dependency of the api check.

$(INTERNAL_MK_PLATFORM_API_FILE): mk-api-stubs-docs

# Check that the API we're building hasn't broken the last-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-mk-last, \
    $(MK_SRC_API_DIR)/$(mk_last_released_sdk_version).txt, \
    $(INTERNAL_MK_PLATFORM_API_FILE), \
    $(FRAMEWORK_MK_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_MK_PLATFORM_REMOVED_API_FILE), \
    -hide 2 -hide 3 -hide 4 -hide 5 -hide 6 -hide 24 -hide 25 -hide 26 -hide 27 \
    -error 7 -error 8 -error 9 -error 10 -error 11 -error 12 -error 13 -error 14 -error 15 \
    -error 16 -error 17 -error 18 , \
    cat $(FRAMEWORK_MK_API_NEEDS_UPDATE_TEXT), \
    check-mk-public-api, \
    $(call doc-timestamp-for,mk-api-stubs) \
    ))

# Check that the API we're building hasn't changed from the not-yet-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-mk-current, \
    $(FRAMEWORK_MK_PLATFORM_API_FILE), \
    $(INTERNAL_MK_PLATFORM_API_FILE), \
    $(FRAMEWORK_MK_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_MK_PLATFORM_REMOVED_API_FILE), \
    -error 2 -error 3 -error 4 -error 5 -error 6 \
    -error 7 -error 8 -error 9 -error 10 -error 11 -error 12 -error 13 -error 14 -error 15 \
    -error 16 -error 17 -error 18 -error 19 -error 20 -error 21 -error 23 -error 24 \
    -error 25 -error 26 -error 27, \
    cat $(FRAMEWORK_MK_API_NEEDS_UPDATE_TEXT), \
    check-mk-public-api, \
    $(call doc-timestamp-for,mk-api-stubs) \
    ))

.PHONY: update-mk-public-api
update-mk-public-api: $(INTERNAL_MK_PLATFORM_API_FILE) | $(ACP)
	@echo "Copying mk_current.txt"
	$(hide) $(ACP) $(INTERNAL_MK_PLATFORM_API_FILE) $(FRAMEWORK_MK_PLATFORM_API_FILE)
	@echo "Copying mk_removed.txt"
	$(hide) $(ACP) $(INTERNAL_MK_PLATFORM_REMOVED_API_FILE) $(FRAMEWORK_MK_PLATFORM_REMOVED_API_FILE)

update-mk-api : update-mk-public-api

.PHONY: update-mk-prebuilts-latest-public-api
current_sdk_release_text_file := $(MK_SRC_API_DIR)/$(mk_last_released_sdk_version).txt

update-mk-prebuilts-latest-public-api: $(FRAMEWORK_MK_PLATFORM_API_FILE) | $(ACP)
	@echo "Publishing mk_current.txt as latest API release"
	$(hide) $(ACP) $(FRAMEWORK_MK_PLATFORM_API_FILE) $(current_sdk_release_text_file)

endif
