#!/bin/bash

# Current directory is luoly
# 该脚本需要一个参数，含义是声音来自人声还是机器回放
# luoly目录下需要有 log_human log_machine 文件，因为 mathanalysis.py 同时需要
# log_human.human log_machine.machine, 所以需要同时为 log_human log_machine排序，但是实时测试时候
# 只能实时产生一组数据（人或者机器），所以luoly目录下要放置提前录好的 log_human log_machine 来补上实时
# 测试的时候空缺的数据


vcomef="$1"	#机器或者人声，其中vcomef变量的意思是 voice come from 也就是声源的类型，“$1”在Linux中代表传给脚本的第一个参数



anvcomef=""	#anvcomef 变量的含义为 another vocie come from, 代表的是另外一个声源类型


if [ "$#" != 1 ]; then   #‘$#’代表传给脚本的参数个数
	echo "Please input source of the voice: "m" or "h" "
	exit 1
fi


cd sound 
rm -rf log
mkdir log
python kws_cch.py 	#该python脚本的作用是开始在四麦克风阵列上接收音频，产生后缀为.wav的音频文件
cd ..
rm log
python generatePar.py sound/log/test 	#该步的作用是调用MAUS技术对收集到.wav文件进行切割，生成需要的TextGrid文件
python generateResult.py sound/log/test		#该步的作用在每个麦克风处是产生TDoA的值，均为该麦克风与麦克风2号之间的TDoA的值


# classify，接下来的作用是判定我们所接收到的声音的声源类型

#下面这个if语句的作用是为变量anvcomef进行赋值操作

if [ "$vcomef" = "h" ]; then
	anvcomef="machine"
elif [ "$vcomef" = "m" ]; then 
	anvcomef="human"
fi

sh sort2_sh.sh log log_${anvcomef} $vcomef 

cp log_human.human log_machine.machine ../libsvm/python
cd ../libsvm/python
python mathanalysis.py log_human.human log_machine.machine newlog_h newlog_m
python format.py newlog_${vcomef} newlog_${vcomef}_formated
python classifyData.py newlog_${vcomef}_formated


exit 0
