#!/bin/bash
# 河北科工大 校园网登录脚本

# 本脚本保存至 /etc/storage/drcom_cron.sh
 
# 添加计划任务
#『系统 - 计划任务』
# */10 * * * * /etc/storage/drcom_cron.sh
 
# --------- 配置区 ---------
server=10.8.200.95
user=88888
password="password"
wlanacname="BRXJMHCN-W2"
# --------- 配置区 ---------
 
html_file="/tmp/drcom_html.log"
login_out_file="/tmp/drcom_login.log"
 
logger -t "【Dr.COM网页认证】" "开始定时检测"
curl -s "http://${server}" > ${html_file}
check_web=`grep "Dr.COMWeb" ${html_file} | head -n1`
check_status=`grep "Dr.COMWebLoginID_0.htm" ${html_file} | head -n1`
# Dr.COMWebLoginID_0.htm 登陆页（未登陆）
# Dr.COMWebLoginID_1.htm 注销页（已登录）
# Dr.COMWebLoginID_2.htm 登陆失败页
# Dr.COMWebLoginID_3.htm 登陆成功页
 
if [[ "$check_web" == "" ]]; then
  logger -t "【Dr.COM网页认证】" "访问认证网页失败"
elif [[ "$check_status" != "" ]]; then
    #尚未登录
    logger -t "【Dr.COM网页认证】" "上网登录窗尚未登录"
    # 此处如果不能正确获取ip则需要进行修改
    ip=$(ifconfig | grep inet | grep -v inet6 | grep -v 127 | grep -v 192 | awk '{print $(NF-2)}' | cut -d ':' -f2)	# 这里如果不能获取到内网ip则自己修改试试
    if [[ "$ip" == "" ]]; then
      logger -t "【Dr.COM网页认证】" "获取当前内网ip失败"
    else
      timestamp_0="$(date +%s)526"
      logger -t "【Dr.COM网页认证】" "当前内网ip：${ip}"
      timestamp_1="$(date +%s)153"
      url="http://${server}:801/eportal/?c=Portal&a=login&callback=dr${timestamp_1}&login_method=1&user_account=${user}&user_password=${password}&wlan_user_ip=${ip}&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=${wlanacname}&jsVersion=3.0&_=${timestamp_0}"
      echo $url
      curl -s "$url" \
      -H 'Connection: keep-alive' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57' \
      -H 'Accept: */*' \
      -H 'Referer: http://${server}/' \
      -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
      > ${login_out_file}
      result=`grep -Eo '"result":"[0-9]+"' ${login_out_file} | sed -r 's/"result":"([0-9]+)"/\1/g'`
      result=`[[ "$result" == 1 || "$result" == "ok" ]] && echo "登陆成功" || echo "登陆失败"`
      logger -t "【Dr.COM网页认证】" "上网登录窗未登录，尝试登陆结果：${result} " `cat ${login_out_file}`
    fi
 
else
    #已经登录
    logger -t "【Dr.COM网页认证】" "上网登录窗之前已登录"
fi
logger -t "【Dr.COM网页认证】" "结束定时检测"
