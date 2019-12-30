#!/bin/bash

BUILD_ROOT=$(pwd)
CONFIG_DIR="${BUILD_ROOT}/config"
OUTPUT_DIR="${BUILD_ROOT}/out"
PRJ_ROOT_DIR="${BUILD_ROOT}/../SampleCalculatorMac"

XCWS_PATH="${PRJ_ROOT_DIR}/SampleCalculatorMac.xcworkspace"
SCHEME_NAME="SampleCalculatorMac"

EXPORT_OTP_PATH="${CONFIG_DIR}/mac_export_options.plist"

PACKAGE_PRJ_DIR="${BUILD_ROOT}/../SampleCalculatorMacPkg"
PACKAGE_PRJ_PATH="${PACKAGE_PRJ_DIR}/SampleCalculatorMac.pkgproj"

function prepare {
	echo "-----------------"
	echo "Preparing..."
	echo "Create folder $TMP_FOLDER"

	rm -rf "${OUTPUT_DIR}"
	mkdir "${OUTPUT_DIR}"
}

function build {
	pwd

	echo "-----------------"
	echo "Archiving..."

	local _archive_path=''
	_archive_path="${OUTPUT_DIR}/${SCHEME_NAME}.xcarchive"

	xcodebuild archive	-workspace "$XCWS_PATH" -scheme ${SCHEME_NAME}  -archivePath "$_archive_path"

	if ! [[ $? == 0 ]]; then
		echo "Archive failed."
		exit 1
	fi

	echo "-----------------"
	echo "Exporting..."

	xcodebuild  -exportArchive -archivePath "$_archive_path" -exportPath "$OUTPUT_DIR" -exportOptionsPlist "${EXPORT_OTP_PATH}" 	
	if ! [[ $? == 0 ]]; then
		echo "Export failed."
		exit 1
	fi

	echo "Done"
	echo "-----------------"
}


function create_pkg {
	echo "-----------------"
	echo "Creating pkg file..."

	echo "Copy to target app folder"
	local _app_name=''
	_app_name="${SCHEME_NAME}.app"
	cp -rf "${OUTPUT_DIR}/${_app_name}" "${PACKAGE_PRJ_DIR}/${_app_name}"

	packagesbuild --verbose "${PACKAGE_PRJ_PATH}"	
}

prepare

build

create_pkg

