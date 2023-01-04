#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================
#	System Required: CentOS 7/8,Debian/ubuntu,oraclelinux
#	Description: BBR+BBRplus+Lotserver
#	Version: 100.0.1.10
#	Author: 千影,cx9208,YLX
#	更新内容及反馈:  https://blog.ylx.me/archives/783.html
#=================================================

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[0;33m'
# SKYBLUE='\033[0;36m'
# PLAIN='\033[0m'

sh_ver="100.0.1.11"
github="raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master"

imgurl=""
headurl=""

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Information]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
Tip="${Green_font_prefix}[Warning]${Font_color_suffix}"

if [ -f "/etc/sysctl.d/bbr.conf" ]; then
  rm -rf /etc/sysctl.d/bbr.conf
fi

#检查连接
checkurl() {
  url=$(curl --max-time 5 --retry 3 --retry-delay 2 --connect-timeout 2 -s --head $1 | head -n 1)
  # echo ${url}
  if [[ ${url} == *200* || ${url} == *302* || ${url} == *308* ]]; then
    echo "OK！"
  else
    echo "Naaah Error happend. :("
    exit 1
  fi
}


check_cn() {
  geoip=$(wget --user-agent="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36" --no-check-certificate -qO- https://api.ip.sb/geoip -T 10 | grep "\"country_code\":\"CN\"")
  if [[ "$geoip" != "" ]]; then
    # echo "下面使用fastgit.org的加速服务"
    # echo ${1//github.com/download.fastgit.org}
    echo https://endpoint.fastgit.org/$1
  else
    echo $1
  fi
}

#安装BBR内核
installbbr() {
  kernel_version="5.9.6"
  bit=$(uname -m)
  rm -rf bbr
  mkdir bbr && cd bbr || exit

  if [[ "${release}" == "centos" ]]; then
    if [[ ${version} == "7" ]]; then
      if [[ ${bit} == "x86_64" ]]; then
        echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
        #github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}' | awk -F '[_]' '{print $3}')
        github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_latest_bbr_' | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}')
        github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{print $4}' | awk -F '[/]' '{print $9}' | awk -F '[-]' '{print $3}')
        echo -e "获取的版本号为:${github_ver}"
        kernel_version=$github_ver
        detele_kernel_head
        headurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{print $4}')
        imgurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep -v 'headers' | grep -v 'devel' | awk -F '"' '{print $4}')
        #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/kernel-headers-${github_ver}-1.x86_64.rpm
        #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/kernel-${github_ver}-1.x86_64.rpm

        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)
        echo -e "正在检查headers下载连接...."
        checkurl $headurl
        echo -e "正在检查内核下载连接...."
        checkurl $imgurl
        wget -N -O kernel-headers-c7.rpm $headurl
        wget -N -O kernel-c7.rpm $imgurl
        yum install -y kernel-c7.rpm
        yum install -y kernel-headers-c7.rpm
      else
        echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
      fi
    fi

  elif [[ "${release}" == "ubuntu" || "${release}" == "debian" ]]; then
    if [[ ${bit} == "x86_64" ]]; then
      echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
      github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Debian_Kernel' | grep '_latest_bbr_' | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}' | awk -F '[/]' '{print $9}' | awk -F '[-]' '{print $3}' | awk -F '[_]' '{print $1}')
      echo -e "获取的版本号为:${github_ver}"
      kernel_version=$github_ver
      detele_kernel_head
      headurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}')
      imgurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep -v 'headers' | grep -v 'devel' | awk -F '"' '{print $4}')
      #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-headers-${github_ver}_${github_ver}-1_amd64.deb
      #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-image-${github_ver}_${github_ver}-1_amd64.deb

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)
      echo -e "正在检查headers下载连接...."
      checkurl $headurl
      echo -e "正在检查内核下载连接...."
      checkurl $imgurl
      wget -N -O linux-headers-d10.deb $headurl
      wget -N -O linux-image-d10.deb $imgurl
      dpkg -i linux-image-d10.deb
      dpkg -i linux-headers-d10.deb
    elif [[ ${bit} == "aarch64" ]]; then
      echo -e "如果下载地址出错，可能当前正在更新，超过半天还是出错请反馈，大陆自行解决污染问题"
      github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Debian_Kernel' | grep '_arm64_' | grep '_bbr_' | head -n 1 | awk -F '"' '{print $4}' | awk -F '[/]' '{print $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}' | awk -F '[/]' '{print $9}' | awk -F '[-]' '{print $3}' | awk -F '[_]' '{print $1}')
      echo -e "获取的版本号为:${github_ver}"
      kernel_version=$github_ver
      detele_kernel_head
      headurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{print $4}')
      imgurl=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep -v 'headers' | grep -v 'devel' | awk -F '"' '{print $4}')
      #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-headers-${github_ver}_${github_ver}-1_amd64.deb
      #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-image-${github_ver}_${github_ver}-1_amd64.deb

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)
      echo -e "正在检查headers下载连接...."
      checkurl $headurl
      echo -e "正在检查内核下载连接...."
      checkurl $imgurl
      wget -N -O linux-headers-d10.deb $headurl
      wget -N -O linux-image-d10.deb $imgurl
      dpkg -i linux-image-d10.deb
      dpkg -i linux-headers-d10.deb
    else
      echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统 !" && exit 1
    fi
  fi

  cd .. && rm -rf bbr

  detele_kernel
  BBR_grub
  echo -e "${Tip} ${Red_font_prefix}请检查上面是否有内核信息，无内核千万别重启${Font_color_suffix}"
  echo -e "${Tip} ${Red_font_prefix}rescue不是正常内核，要排除这个${Font_color_suffix}"
  echo -e "${Tip} 重启VPS后，请重新运行脚本开启${Red_font_prefix}BBR${Font_color_suffix}"
  check_kernel
  stty erase '^H' && read -p "需要重启VPS后，才能开启BBR，是否现在重启 ? [Y/n] :" yn
  [ -z "${yn}" ] && yn="y"
  if [[ $yn == [Yy] ]]; then
    echo -e "${Info} VPS 重启中..."
    reboot
  fi
  #echo -e "${Tip} 内核安装完毕，请参考上面的信息检查是否安装成功及手动调整内核启动顺序"
}


#安装bbr2内核 集成到xanmod内核了
#安装bbrplus 新内核
#2021.3.15 开始由https://github.com/UJX6N/bbrplus-5.19 替换bbrplusnew
#2021.4.12 地址更新为https://github.com/ylx2016/kernel/releases
#2021.9.2 再次改为https://github.com/UJX6N/bbrplus
#2022.9.6 改为https://github.com/UJX6N/bbrplus-5.19
#2022.11.24 改为https://github.com/UJX6N/bbrplus-6.x_stable

#BBR+fq
startbbrfq() {
  remove_bbr_lotserver
  echo "net.core.default_qdisc=fq" >>/etc/sysctl.d/99-sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.d/99-sysctl.conf
  sysctl --system
  echo -e "${Info}BBR+FQ set！Reboot needed"
}

#remove_bbr_lotserver
remove_bbr_lotserver() {
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  sysctl --system

  rm -rf bbrmod

  if [[ -e /appex/bin/lotServer.sh ]]; then
    echo | bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) uninstall
  fi
  clear
  # echo -e "${Info}:清除bbr/lotserver加速完成。"
  # sleep 1s
}

#Removes all optimizations
remove_all() {
  rm -rf /etc/sysctl.d/*.conf
  #rm -rf /etc/sysctl.conf
  #touch /etc/sysctl.conf
  if [ ! -f "/etc/sysctl.conf" ]; then
    touch /etc/sysctl.conf
  else
    cat /dev/null >/etc/sysctl.conf
  fi
  sysctl --system
  sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
  sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
  sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf

  sed -i '/soft nofile/d' /etc/security/limits.conf
  sed -i '/hard nofile/d' /etc/security/limits.conf
  sed -i '/soft nproc/d' /etc/security/limits.conf
  sed -i '/hard nproc/d' /etc/security/limits.conf

  sed -i '/ulimit -SHn/d' /etc/profile
  sed -i '/ulimit -SHn/d' /etc/profile
  sed -i '/required pam_limits.so/d' /etc/pam.d/common-session

  systemctl daemon-reload

  rm -rf bbrmod
  sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  sed -i '/fs.file-max/d' /etc/sysctl.conf
  sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
  sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
  sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
  sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
  sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
  sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
  sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
  sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
  sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
  if [[ -e /appex/bin/lotServer.sh ]]; then
    bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) uninstall
  fi
  clear
  echo -e "${Info}:清除加速完成。"
  sleep 1s
}

#Close IPv6
closeipv6() {
  clear
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

  echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >>/etc/sysctl.d/99-sysctl.conf
  sysctl --system
  echo -e "${Info}禁用IPv6结束，可能需要重启！"
}

#Enable IPv6
openipv6() {
  clear
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.all.accept_ra/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.accept_ra/d' /etc/sysctl.conf

  echo "net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2" >>/etc/sysctl.d/99-sysctl.conf
  sysctl --system
  echo -e "${Info}开启IPv6结束，可能需要重启！"
}

start_func() {
  clear
  startbbrfq
  check_status
  get_system_info
  echo && echo -e " System Information: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix} "
  if [[ ${kernel_status} == "noinstall" ]]; then
    echo -e " Current status: ${Green_font_prefix}Not Installed${Font_color_suffix} Accelerated core ${Red_font_prefix}Please install the kernel first${Font_color_suffix}"
  else
    echo -e " Current status: ${Green_font_prefix}Installed${Font_color_suffix} ${Red_font_prefix}${kernel_status}${Font_color_suffix} Accelerated core , ${Green_font_prefix}${run_status}${Font_color_suffix}"
  fi
  echo -e " The current congestion control algorithm is: ${Green_font_prefix}${net_congestion_control}${Font_color_suffix} The current queue algorithm is: ${Green_font_prefix}${net_qdisc}${Font_color_suffix} "
    stty erase '^H' && read -p "Reboot to apply ? [Y/n] :" yn
  [ -z "${yn}" ] && yn="y"
  if [[ $yn == [Yy] ]]; then
    echo -e "${Info} VPS will reboot in the next 5 seconds, Cancel: Ctrl + C . . . . ."
    sleep 5s
    reboot
  fi
}
#############内核管理组件#############

#删除多余内核
detele_kernel() {
  if [[ "${release}" == "centos" ]]; then
    rpm_total=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
    if [ "${rpm_total}" ] >"1"; then
      echo -e "检测到 ${rpm_total} 个其余内核，开始卸载..."
      for ((integer = 1; integer <= ${rpm_total}; integer++)); do
        rpm_del=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
        echo -e "开始卸载 ${rpm_del} 内核..."
        rpm --nodeps -e ${rpm_del}
        echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
      done
      echo --nodeps -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    deb_total=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l)
    if [ "${deb_total}" ] >"1"; then
      echo -e "检测到 ${deb_total} 个其余内核，开始卸载..."
      for ((integer = 1; integer <= ${deb_total}; integer++)); do
        deb_del=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer})
        echo -e "开始卸载 ${deb_del} 内核..."
        apt-get purge -y ${deb_del}
        apt-get autoremove -y
        echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
      done
      echo -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  fi
}

detele_kernel_head() {
  if [[ "${release}" == "centos" ]]; then
    rpm_total=$(rpm -qa | grep kernel-headers | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
    if [ "${rpm_total}" ] >"1"; then
      echo -e "检测到 ${rpm_total} 个其余head内核，开始卸载..."
      for ((integer = 1; integer <= ${rpm_total}; integer++)); do
        rpm_del=$(rpm -qa | grep kernel-headers | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
        echo -e "开始卸载 ${rpm_del} headers内核..."
        rpm --nodeps -e ${rpm_del}
        echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
      done
      echo --nodeps -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    deb_total=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "${kernel_version}" | wc -l)
    if [ "${deb_total}" ] >"1"; then
      echo -e "检测到 ${deb_total} 个其余head内核，开始卸载..."
      for ((integer = 1; integer <= ${deb_total}; integer++)); do
        deb_del=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer})
        echo -e "开始卸载 ${deb_del} headers内核..."
        apt-get purge -y ${deb_del}
        apt-get autoremove -y
        echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
      done
      echo -e "内核卸载完毕，继续..."
    else
      echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
    fi
  fi
}


#更新引导
BBR_grub() {
  if [[ "${release}" == "centos" ]]; then
    if [[ ${version} == "6" ]]; then
      if [ -f "/boot/grub/grub.conf" ]; then
        sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
      elif [ -f "/boot/grub/grub.cfg" ]; then
        grub-mkconfig -o /boot/grub/grub.cfg
        grub-set-default 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
        grub-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub-set-default 0
      elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
        grub-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub-set-default 0
      else
        echo -e "${Error} grub.conf/grub.cfg 找不到，请检查."
        exit
      fi
    elif [[ ${version} == "7" ]]; then
      if [ -f "/boot/grub2/grub.cfg" ]; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
        grub2-set-default 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub2-set-default 0
      elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub2-set-default 0
      else
        echo -e "${Error} grub.cfg 找不到，请检查."
        exit
      fi
    elif [[ ${version} == "8" ]]; then
      if [ -f "/boot/grub2/grub.cfg" ]; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
        grub2-set-default 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; then
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub2-set-default 0
      elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub2-set-default 0
      else
        echo -e "${Error} grub.cfg 找不到，请检查."
        exit
      fi
      grubby --info=ALL | awk -F= '$1=="kernel" {print i++ " : " $2}'
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    if _exists "update-grub"; then
      update-grub
    elif [ -f "/usr/sbin/update-grub" ]; then
      /usr/sbin/update-grub
    else
      apt install grub2-common -y
      update-grub
    fi
    #exit 1
  fi
}

#简单的检查内核
check_kernel() {
  echo -e "${Tip} 鉴于1次人工检查有人不看，下面是2次脚本简易检查内核，开始匹配 /boot/vmlinuz-* 文件"
  ls /boot/vmlinuz-* -I rescue -1 || echo -e "${Error} 没有匹配到 /boot/vmlinuz-* 文件，很有可能没有内核，谨慎重启，在结合上面第一道检查确认没有内核的情况下，你可以尝试按9切换到不卸载内核选择30安装默认内核救急，此时你应该给我反馈！" && exit
}

#############内核管理组件#############

#############系统检测组件#############

#检查系统
check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi

  #from https://github.com/oooldking

  _exists() {
    local cmd="$1"
    if eval type type >/dev/null 2>&1; then
      eval type "$cmd" >/dev/null 2>&1
    elif command >/dev/null 2>&1; then
      command -v "$cmd" >/dev/null 2>&1
    else
      which "$cmd" >/dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
  }

  get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
  }
  get_system_info() {
    opsy=$(get_opsy)
    arch=$(uname -m)
    kern=$(uname -r)

    virt_check
  }
  # from LemonBench
  virt_check() {
    if [ -f "/usr/bin/systemd-detect-virt" ]; then
      Var_VirtType="$(/usr/bin/systemd-detect-virt)"
      if [ "${Var_VirtType}" = "qemu" ]; then
        virtual="QEMU"
      elif [ "${Var_VirtType}" = "kvm" ]; then
        virtual="KVM"
      elif [ "${Var_VirtType}" = "zvm" ]; then
        virtual="S390 Z/VM"
      elif [ "${Var_VirtType}" = "vmware" ]; then
        virtual="VMware"
      elif [ "${Var_VirtType}" = "microsoft" ]; then
        virtual="Microsoft Hyper-V"
      elif [ "${Var_VirtType}" = "xen" ]; then
        virtual="Xen Hypervisor"
      elif [ "${Var_VirtType}" = "bochs" ]; then
        virtual="BOCHS"
      elif [ "${Var_VirtType}" = "uml" ]; then
        virtual="User-mode Linux"
      elif [ "${Var_VirtType}" = "parallels" ]; then
        virtual="Parallels"
      elif [ "${Var_VirtType}" = "bhyve" ]; then
        virtual="FreeBSD Hypervisor"
      elif [ "${Var_VirtType}" = "openvz" ]; then
        virtual="OpenVZ"
      elif [ "${Var_VirtType}" = "lxc" ]; then
        virtual="LXC"
      elif [ "${Var_VirtType}" = "lxc-libvirt" ]; then
        virtual="LXC (libvirt)"
      elif [ "${Var_VirtType}" = "systemd-nspawn" ]; then
        virtual="Systemd nspawn"
      elif [ "${Var_VirtType}" = "docker" ]; then
        virtual="Docker"
      elif [ "${Var_VirtType}" = "rkt" ]; then
        virtual="RKT"
      elif [ -c "/dev/lxss" ]; then
        Var_VirtType="wsl"
        virtual="Windows Subsystem for Linux (WSL)"
      elif [ "${Var_VirtType}" = "none" ]; then
        Var_VirtType="dedicated"
        virtual="None"
        local Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
          Var_VirtType="Unknown"
          virtual="Unknown with SeaBIOS BIOS"
        else
          Var_VirtType="dedicated"
          virtual="Dedicated with ${Var_BIOSVendor} BIOS"
        fi
      fi
    elif [ ! -f "/usr/sbin/virt-what" ]; then
      Var_VirtType="Unknown"
      virtual="[Error: virt-what not found !]"
    elif [ -f "/.dockerenv" ]; then
      Var_VirtType="docker"
      virtual="Docker"
    elif [ -c "/dev/lxss" ]; then
      Var_VirtType="wsl"
      virtual="Windows Subsystem for Linux (WSL)"
    else
      Var_VirtType="$(virt-what | xargs)"
      local Var_VirtTypeCount
      Var_VirtTypeCount="$(echo $Var_VirtTypeCount | wc -l)"
      if [ "${Var_VirtTypeCount}" -gt "1" ]; then
        virtual="echo ${Var_VirtType}"
        Var_VirtType="$(echo ${Var_VirtType} | head -n1)"
      elif [ "${Var_VirtTypeCount}" -eq "1" ] && [ "${Var_VirtType}" != "" ]; then
        virtual="${Var_VirtType}"
      else
        local Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
          Var_VirtType="Unknown"
          virtual="Unknown with SeaBIOS BIOS"
        else
          Var_VirtType="dedicated"
          virtual="Dedicated with ${Var_BIOSVendor} BIOS"
        fi
      fi
    fi
  }


  if [[ "${release}" == "centos" ]]; then
    if (yum list installed ca-certificates | grep '202'); then
      echo 'CA证书检查OK'
    else
      echo 'CA证书检查不通过，处理中'
      yum install ca-certificates -y
      update-ca-trust force-enable
    fi
    if ! type curl >/dev/null 2>&1; then
      echo 'curl 未安装 安装中'
      yum install curl -y
    else
      echo 'curl 已安装，继续'
    fi

    if ! type wget >/dev/null 2>&1; then
      echo 'wget 未安装 安装中'
      yum install curl -y
    else
      echo 'wget 已安装，继续'
    fi

    if ! type dmidecode >/dev/null 2>&1; then
      echo 'dmidecode 未安装 安装中'
      yum install dmidecode -y
    else
      echo 'dmidecode 已安装，继续'
    fi

  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    if (apt list --installed | grep 'ca-certificates' | grep '202'); then
      echo 'CA证书检查OK'
    else
      echo 'CA证书检查不通过，处理中'
      apt-get update || apt-get --allow-releaseinfo-change update && apt-get install ca-certificates -y
      update-ca-certificates
    fi
    if ! type curl >/dev/null 2>&1; then
      echo 'curl 未安装 安装中'
      apt-get update || apt-get --allow-releaseinfo-change update && apt-get install curl -y
    else
      echo 'curl 已安装，继续'
    fi

    if ! type wget >/dev/null 2>&1; then
      echo 'wget 未安装 安装中'
      apt-get update || apt-get --allow-releaseinfo-change update && apt-get install wget -y
    else
      echo 'wget 已安装，继续'
    fi

    if ! type dmidecode >/dev/null 2>&1; then
      echo 'dmidecode 未安装 安装中'
      apt-get update || apt-get --allow-releaseinfo-change update && apt-get install dmidecode -y
    else
      echo 'dmidecode 已安装，继续'
    fi
  fi
}

check_version() {
  if [[ -s /etc/redhat-release ]]; then
    version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
  else
    version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
  fi
  bit=$(uname -m)

}


check_sys_bbr() {
  check_version
  if [[ "${release}" == "centos" ]]; then
    if [[ ${version} == "7" ]]; then
      installbbr
    else
      echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    apt-get --fix-broken install -y && apt-get autoremove -y
    installbbr
  else
    echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
  fi
}

check_sys_bbrplus() {
  check_version
  if [[ "${release}" == "centos" ]]; then
    if [[ ${version} == "7" ]]; then
      installbbrplus
    else
      echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    apt-get --fix-broken install -y && apt-get autoremove -y
    installbbrplus
  else
    echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
  fi
}

check_sys_bbrplusnew() {
  check_version
  if [[ "${release}" == "centos" ]]; then
    #if [[ ${version} == "7" ]]; then
    if [[ ${version} == "7" || ${version} == "8" ]]; then
      installbbrplusnew
    else
      echo -e "${Error} BBRplusNew内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
    apt-get --fix-broken install -y && apt-get autoremove -y
    installbbrplusnew
  else
    echo -e "${Error} BBRplusNew内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
  fi
}


check_sys_Lotsever() {
  check_version
  bit=$(uname -m)
  if [[ ${bit} != "x86_64" ]]; then
    echo -e "${Error} 不支持x86_64以外的系统 !" && exit 1
  fi
  if [[ "${release}" == "centos" ]]; then
    if [[ ${version} == "6" ]]; then
      kernel_version="2.6.32-504"
      installlot
    elif [[ ${version} == "7" ]]; then
      yum -y install net-tools
      kernel_version="4.11.2-1"
      installlot
    else
      echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  elif [[ "${release}" == "debian" ]]; then
    if [[ ${version} == "7" || ${version} == "8" ]]; then
      if [[ ${bit} == "x86_64" ]]; then
        kernel_version="3.16.0-4"
        installlot
      elif [[ ${bit} == "i386" ]]; then
        kernel_version="3.2.0-4"
        installlot
      fi
    elif [[ ${version} == "9" ]]; then
      if [[ ${bit} == "x86_64" ]]; then
        kernel_version="4.9.0-4"
        installlot
      fi
    else
      echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  elif [[ "${release}" == "ubuntu" ]]; then
    if [[ ${version} -ge "12" ]]; then
      if [[ ${bit} == "x86_64" ]]; then
        kernel_version="4.4.0-47"
        installlot
      elif [[ ${bit} == "i386" ]]; then
        kernel_version="3.13.0-29"
        installlot
      fi
    else
      echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
    fi
  else
    echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
  fi
}

#check
check_status() {
  kernel_version=$(uname -r | awk -F "-" '{print $1}')
  kernel_version_full=$(uname -r)
  net_congestion_control=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
  net_qdisc=$(cat /proc/sys/net/core/default_qdisc | awk '{print $1}')
  #kernel_version_r=$(uname -r | awk '{print $1}')
  # if [[ ${kernel_version_full} = "4.14.182-bbrplus" || ${kernel_version_full} = "4.14.168-bbrplus" || ${kernel_version_full} = "4.14.98-bbrplus" || ${kernel_version_full} = "4.14.129-bbrplus" || ${kernel_version_full} = "4.14.160-bbrplus" || ${kernel_version_full} = "4.14.166-bbrplus" || ${kernel_version_full} = "4.14.161-bbrplus" ]]; then
  if [[ ${kernel_version_full} == *bbrplus* ]]; then
    kernel_status="BBRplus"
    # elif [[ ${kernel_version} = "3.10.0" || ${kernel_version} = "3.16.0" || ${kernel_version} = "3.2.0" || ${kernel_version} = "4.4.0" || ${kernel_version} = "3.13.0"  || ${kernel_version} = "2.6.32" || ${kernel_version} = "4.9.0" || ${kernel_version} = "4.11.2" || ${kernel_version} = "4.15.0" ]]; then
    # kernel_status="Lotserver"
  elif [[ ${kernel_version_full} == *4.9.0-4* || ${kernel_version_full} == *4.15.0-30* || ${kernel_version_full} == *4.8.0-36* || ${kernel_version_full} == *3.16.0-77* || ${kernel_version_full} == *3.16.0-4* || ${kernel_version_full} == *3.2.0-4* || ${kernel_version_full} == *4.11.2-1* || ${kernel_version_full} == *2.6.32-504* || ${kernel_version_full} == *4.4.0-47* || ${kernel_version_full} == *3.13.0-29 || ${kernel_version_full} == *4.4.0-47* ]]; then
    kernel_status="Lotserver"
  elif [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "4" ]] && [[ $(echo ${kernel_version} | awk -F'.' '{print $2}') -ge 9 ]] || [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "5" ]] || [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "6" ]]; then
    kernel_status="BBR"
  else
    kernel_status="noinstall"
  fi

  if [[ ${kernel_status} == "BBR" ]]; then
    run_status=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
    if [[ ${run_status} == "bbr" ]]; then
      run_status=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
      if [[ ${run_status} == "bbr" ]]; then
        run_status="BBR Started"
      else
        run_status="BBR Failed"
      fi
    elif [[ ${run_status} == "bbr2" ]]; then
      run_status=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
      if [[ ${run_status} == "bbr2" ]]; then
        run_status="BBR2启动成功"
      else
        run_status="BBR2启动失败"
      fi
    elif [[ ${run_status} == "tsunami" ]]; then
      run_status=$(lsmod | grep "tsunami" | awk '{print $1}')
      if [[ ${run_status} == "tcp_tsunami" ]]; then
        run_status="BBR魔改版启动成功"
      else
        run_status="BBR魔改版启动失败"
      fi
    elif [[ ${run_status} == "nanqinlang" ]]; then
      run_status=$(lsmod | grep "nanqinlang" | awk '{print $1}')
      if [[ ${run_status} == "tcp_nanqinlang" ]]; then
        run_status="暴力BBR魔改版启动成功"
      else
        run_status="暴力BBR魔改版启动失败"
      fi
    else
      run_status="未安装加速模块"
    fi

  elif [[ ${kernel_status} == "Lotserver" ]]; then
    if [[ -e /appex/bin/lotServer.sh ]]; then
      run_status=$(bash /appex/bin/lotServer.sh status | grep "LotServer" | awk '{print $3}')
      if [[ ${run_status} == "running!" ]]; then
        run_status="启动成功"
      else
        run_status="启动失败"
      fi
    else
      run_status="未安装加速模块"
    fi
  elif [[ ${kernel_status} == "BBRplus" ]]; then
    run_status=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
    if [[ ${run_status} == "bbrplus" ]]; then
      run_status=$(cat /proc/sys/net/ipv4/tcp_congestion_control | awk '{print $1}')
      if [[ ${run_status} == "bbrplus" ]]; then
        run_status="BBRplus启动成功"
      else
        run_status="BBRplus启动失败"
      fi
    elif [[ ${run_status} == "bbr" ]]; then
      run_status="BBR Started"
    else
      run_status="未安装加速模块"
    fi
  fi
}

#############start#############
check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
start_func
