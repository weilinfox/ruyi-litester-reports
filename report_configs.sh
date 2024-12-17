
####################################
# @Author  : weilinfox
# @email   : caiweilin@iscas.ac.cn
# @Date    : 2024-12-17 14:23:31
# @License : Apache-2.0
# @Version : 1.0
# @Desc    : Static configs of report
#####################################

# ruyi variables
if [ -n "$RUYI_VERSION" ]
	case "$(uname -m)" in
		x86_64)
			RUYI_ARCH="amd64"
			;;
		aarch64)
			RUYI_ARCH="arm64"
			;;
		riscv64)
			RUYI_ARCH="riscv64"
			;;
	esac
	RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/releases/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"

	TEST_ARCH="$RUYI_ARCH"
	TEST_PKG_LINK="$RUYI_LINK"
	TEST_VERSION="$RUYI_VERSION"
fi

TEST_ARCH="${TEST_ARCH:?}"
TEST_LITESTER_PATH="${TEST_LITESTER_PATH:?}"
TEST_PKG_LINK="${TEST_PKG_LINK:?}"
TEST_REPO="https://gitee.com/yunxiangluo/ruyisdk-test/tree/master/${TEST_START_TIME:?}"
TEST_REPO_RAW="https://gitee.com/yunxiangluo/ruyisdk-test/raw/master/${TEST_START_TIME:?}"
TEST_VERSION="${TEST_VERSION:?}"

