#/bin/sh

git clone https://gitlab.com/ApexAI/performance_test.git

git --git-dir=performance_test/.git --work-tree=./performance_test/ checkout foxy

docker build ./performance_test -f performance_test/dockerfiles/Dockerfile.FastDDS -t 5g_era_performance_image