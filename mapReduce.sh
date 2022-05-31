#!/bin/bash


ITER="100000" # iterations number & scale (if not mentioned when executing script)
SCALE="d"

# input& output config
HADOOP_INPUT="input"
HADOOP_OUTPUT="output"
JAR="target/MapReduce-1.0-SNAPSHOT-jar-with-dependencies.jar"
RESULT="result.txt"


    ### Getting cmd arguments: amount of iterations & scale
    echo
    echo
    echo "-------------------------Getting cmd args-------------------------------"
    while [ -n "$1" ]
    do
        case "$1" in
                    "--iter")
                        shift 1
                        ITER="$1"
                        echo "ITER: "
                        echo $ITER;;

                    "--scale")
                        shift 1
                        SCALE="$1" # s, m, h, d
                        #
                        # check true scale
                        ok=0
                        for scale in s m h d
                        do
                            test "$SCALE" = "$scale" && ok="1"
                        done
                        #
                        test "$ok" = "0" && \
                            { exit 1; };;
        esac
        shift 1
    done

    echo
    echo "Arguments:"
    echo "ITER: "
    echo $ITER
    echo "SCALE"
    echo $SCALE
    echo
    ###

    ### Building project jar
    echo
    echo
    echo "-------------------------Building project jar---------------------------"
    mvn clean
    mvn compile
    mvn package
    test -f $JAR || \
            { echo "No jar file"; return 1; }
    ###

    ### Starting Hadoop services
    echo
    echo
    echo "-----------------------Starting Hadoop services-------------------------"
    start-dfs.sh
    start-yarn.sh
    hadoop dfsadmin -safemode leave
    jps
    ###

    ### Clearing hdfs and local input, output, result files
    echo
    echo
    echo "--------------------Clearing space for input & output-------------------"
    hdfs dfs -rm -r $HADOOP_OUTPUT
    hdfs dfs -rm -r $HADOOP_INPUT

    # clearing local input, output, result files
#    rm -r $HADOOP_INPUT
#    rm -r $HADOOP_OUTPUT
    rm $RESULT
    ###

    ### Preparing Hadoop job
    echo
    echo
    echo "-----------------Generating test data + preparing input-----------------"

    hdfs dfs -put $HADOOP_INPUT $HADOOP_INPUT
    ###

    ### Running Hadoop job
    echo
    echo
    echo "------------------------Running Hadoop job------------------------------"
    yarn jar $JAR $HADOOP_INPUT $HADOOP_OUTPUT $SCALE `realpath ./metricsRef.txt`
    ###

    ### Introducing results of work
    echo
    echo
    echo "---------------------------Result of work-------------------------------"
    hdfs dfs -ls $HADOOP_OUTPUT
    mkdir $HADOOP_OUTPUT
    hdfs dfs -text $HADOOP_OUTPUT/part-r-00000 &> $RESULT
    hdfs dfs -get $HADOOP_OUTPUT
    ###

    ### Cleaning and ending work
    echo
    echo
    echo "-------------------------Clearing and ending work-----------------------"
    echo
    echo -n "Hit enter to clear hdfs & local files, stop Hadoop and execute mvn clean";
    read;

    # clearing local & hdfs files
    hdfs dfs -rm -r $HADOOP_OUTPUT
    hdfs dfs -rm -r $HADOOP_INPUT
    rm -r $HADOOP_INPUT
    rm -r $HADOOP_OUTPUT
    rm $RESULT

    # stop Hadoop
    stop-dfs.sh
    stop-yarn.sh

    # mvn clean
    mvn clean
    ###

    exit 0
