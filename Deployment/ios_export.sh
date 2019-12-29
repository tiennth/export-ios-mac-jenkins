#!/bin/bash

BUILD_ROOT=$(pwd)
CONFIG_DIR="${BUILD_ROOT}/config"
OUTPUT_DIR="${BUILD_ROOT}/out"
PRJ_ROOT_DIR="${BUILD_ROOT}/../SampleCalculator"

XCWS_PATH="${PRJ_ROOT_DIR}/SampleCalculator.xcworkspace"
SCHEME_NAME="SampleCalculator"

EXPORT_OTP_PATH="${CONFIG_DIR}/ios_export_options.plist"

INFOPLIST_PATH="${PRJ_ROOT_DIR}/SampleCalculator/Info.plist"

EXPORT_FILE_PATH=""

function prepare {
	echo "-----------------"
	echo "Preparing..."

	rm -rf "${OUTPUT_DIR}"
	mkdir "${OUTPUT_DIR}"
}

function increaseBuildNumber {
	local _app_build_number=''

	_app_build_number=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFOPLIST_PATH}")
	_app_build_number=$((_app_build_number+1))
	echo ${_app_build_number}

	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${_app_build_number}" "${INFOPLIST_PATH}"
	/usr/libexec/PlistBuddy -c "Save" "${INFOPLIST_PATH}"
}

function commitChanges {
	# Upload success, commit new build number.
	git add "${INFOPLIST_PATH}"
	git commit -m "Auto increase build number"
	git push origin HEAD:deployment
}

function build {
	pwd

	echo "-----------------"
	echo "Archiving..."

	local _archive_path=''
	_archive_path="${OUTPUT_DIR}/${SCHEME_NAME}.xcarchive"

	xcodebuild -workspace "${XCWS_PATH}" -scheme ${SCHEME_NAME} -sdk iphoneos -configuration Release archive -archivePath "${_archive_path}"
	if ! [[ $? == 0 ]]; then
		echo "Archive failed."
		exit 1
	fi

	echo "-----------------"
	echo "Exporting..."

	xcodebuild -exportArchive -archivePath "${_archive_path}" -exportOptionsPlist "${EXPORT_OTP_PATH}" -exportPath "${OUTPUT_DIR}"
	if ! [[ $? == 0 ]]; then
		echo "Export failed."
		exit 1
	fi

	echo "Done"
	echo "-----------------"
}

function artifact {
	local _app_version=''
	local _app_build_number=''
	local _app_name=''
	local _package_name=''

	_app_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFOPLIST_PATH")
	_app_build_number=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST_PATH")
	_app_name="${SCHEME_NAME}"
	_package_name="${_app_name}_v${_app_version}.b${_app_build_number}"

	mv "${OUTPUT_DIR}/${_app_name}.ipa" "${OUTPUT_DIR}/${_package_name}.ipa"

	EXPORT_FILE_PATH="$OUTPUT_DIR/${_package_name}"

	echo "Done"
	echo "-----------------"
}

function upload {

	echo "IPA File path: $EXPORT_FILE_PATH"
	altool="$(dirname "$(xcode-select -p)")/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"
	
	echo "Validating app..."
	time "$altool" --validate-app --type ios --file "${EXPORT_FILE_PATH}" --username "$1" --password "$2"
	if ! [[ $? == 0 ]]; then
		echo "Validation failed"
		exit 1
	fi

	echo "Uploading app to iTC..."
	time "$altool" --upload-app --type ios --file "${EXPORT_FILE_PATH}" --username "$1" --password "$2"
	if ! [[ $? == 0 ]]; then
		echo "Upload failed."
		exit 1
	fi

	commitChanges
}

prepare

# If need upload, increase build number first
if [ "$1" = true ]; then
	increaseBuildNumber
fi

build

artifact

# If need upload
if [ "$1" = true ]; then
	upload "$2" "$3"
fi

