#!/usr/bin/bash

####################################
# @Author  : weilinfox
# @email   : caiweilin@iscas.ac.cn
# @Date    : 2024-03-26 13:18:31
# @License : Apache-2.0
# @Version : 1.0
# @Desc    : Generate test report
#####################################

SELF_PATH=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)
RUN_PATH=$(pwd)

report_name_js="$SELF_PATH"/report_names.json
report_config_sh="$SELF_PATH"/report_configs.sh
report_config_my_sh="$SELF_PATH"/report_my_configs.sh
report_tmpl_dir="$SELF_PATH"/report_tmpl

temp_dir=/tmp/ruyi_report
report_name=`jq -r .\"${1:?}\" $report_name_js`
log_name="${1:?}"

. "$report_config_my_sh"
. "$report_config_sh"

[ -z "$report_name" ] && {
	echo Unsupported distro
	exit -1
}

[ ! -f $report_tmpl_dir/26test_log.md ] && {
	echo 26test_log.md not appears
	exit -1
}

[[ -d $temp_dir ]] && rm -rf $temp_dir
mkdir $temp_dir

cp ${report_tmpl_dir}/*.md ${report_tmpl_dir}/${1:?}/*.md $temp_dir/

for f in `ls ${temp_dir} | sort`; do
	echo Find template ${temp_dir}/$f
	cat ${temp_dir}/$f >> $TEST_LITESTER_PATH/my.md
done
rm -rf $temp_dir

sed -i "s/{{ruyi_arch}}/${TEST_ARCH:?}/g" $TEST_LITESTER_PATH/my.md
sed -i "s/{{ruyi_version}}/${TEST_VERSION:?}/g" $TEST_LITESTER_PATH/my.md
sed -i "s|{{ruyi_link}}|${TEST_PKG_LINK:?}|g" $TEST_LITESTER_PATH/my.md
sed -i "s|{{ruyitest_repo}}|${TEST_REPO:?}|g" $TEST_LITESTER_PATH/my.md
sed -i "s|{{ruyitest_repo_raw}}|${TEST_REPO_RAW:?}|g" $TEST_LITESTER_PATH/my.md
sed -i "s/{{log_name}}/$log_name/g" $TEST_LITESTER_PATH/my.md

mkdir "${TEST_LITESTER_PATH}"/logs
# format test logs name
if [ -d "${TEST_LITESTER_PATH}"/mugen_log ]; then
	for f in $(find "${TEST_LITESTER_PATH}"/mugen_log -type f); do
		mv "$f" "$(echo "$f" | sed "s/:/_/g")"
	done

	mv -v "${TEST_LITESTER_PATH}"/mugen_log "${TEST_LITESTER_PATH}"/logs/
fi
mv -v "${TEST_LITESTER_PATH}"/*.log "${TEST_LITESTER_PATH}"/logs/

ruyi_conclusion="没有发现问题"
ruyi_testsuites=4
ruyi_success=0
ruyi_failed=0
# get failed logs
mkdir "${TEST_LITESTER_PATH}"/logs_failed
for f in `ls "${TEST_LITESTER_PATH}"/logs/*.log`; do
	if grep " - ERROR - failed to execute the case." "$f"; then
		cp -v "$f" "${TEST_LITESTER_PATH}"/logs_failed
		((ruyi_failed++))
	elif grep "FAIL:" "$f"; then
		cp -v "$f" "${TEST_LITESTER_PATH}"/logs_failed
		((ruyi_failed++))
	else
		((ruyi_success++))
	fi
done
rmdir --ignore-fail-on-non-empty "${TEST_LITESTER_PATH}"/logs_failed

if [ "$ruyi_failed" -gt 0 ]; then
	ruyi_conclusion="此处添加评论"
fi
sed -i "s/{{ruyi_conclusion}}/$ruyi_conclusion/g" $TEST_LITESTER_PATH/my.md
sed -i "s/{{ruyi_testsuites}}/$ruyi_testsuites/g" $TEST_LITESTER_PATH/my.md
sed -i "s/{{ruyi_success}}/$ruyi_success/g" $TEST_LITESTER_PATH/my.md
sed -i "s/{{ruyi_failed}}/$ruyi_failed/g" $TEST_LITESTER_PATH/my.md
# rename md report
[ -d "$TEST_LITESTER_PATH"/ruyi_report ] || mkdir "$TEST_LITESTER_PATH"/ruyi_report
mv -v $TEST_LITESTER_PATH/my.md $TEST_LITESTER_PATH/ruyi_report/$report_name.md

# pack all logs
cd "${TEST_LITESTER_PATH}"
rm *.md
[ -d ./logs_failed ] && mv logs_failed "${log_name}"_failed && tar zcvf ruyi-test-logs_failed.tar.gz ./"${log_name}"_failed || touch ruyi-test-logs_failed.tar.gz
tar zcvf ruyi-test-logs.tar.gz ./"${log_name}"
cd $RUN_PATH

