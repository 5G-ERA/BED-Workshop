#/bin/sh

git clone https://gitlab.com/ApexAI/performance_test.git

git --git-dir=performance_test/.git --work-tree=./performance_test/ checkout foxy

docker build ./performance_test -f dockerfiles/Dockerfile.FastDDS -t performance_test_fast_dds