#!/bin/bash

sudo apt update

# 필요한 패키지 및 라이브러리 설치 확인 및 설치
packages=("openjdk-17-jre-headless" "python3-pip" "wget" "unzip" "curl" "git")
for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q $package; then
        sudo apt install -y $package
    else
        echo "$package is already installed."
    fi
done

# 필요한 Python 패키지 설치 확인 및 설치
python_packages=("requests" "python-sonarqube-api")
for python_package in "${python_packages[@]}"; do
    if ! python3 -c "import $python_package" &>/dev/null; then
        sudo pip install $python_package
    else
        echo "$python_package is already installed."
    fi
done

# SonarQube 및 SonarScanner가 설치되어 있는지 확인
if ! [ -d "/opt/sonarqube" ]; then
    # SonarQube 설치
    cd /opt
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
    unzip sonarqube-10.4.1.88267.zip
    mv /opt/sonarqube-10.4.1.88267 /opt/sonarqube
    chmod 777 /opt/sonarqube

    # 'sonar' 사용자 추가 및 권한 설정
    sudo adduser --system --no-create-home --group sonar
    sudo chown -R sonar:sonar /opt/sonarqube
else
    echo "SonarQube is already installed."
fi

# SonarQube 시작
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start

if ! [ -d "/opt/sonarscanner" ]; then
    # SonarScanner 설치
    cd /opt
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
    unzip sonar-scanner-cli-5.0.1.3006-linux.zip
    mv /opt/sonar-scanner-5.0.1.3006-linux /opt/sonarscanner

    # SonarScanner 권한 부여
    chmod 777 /opt/sonarscanner
else
    echo "SonarScanner is already installed."
fi

python3 <<END
from sonarqube import SonarQubeClient

# SonarQube 서버 URL 및 인증 정보 설정
url = "http://localhost:9000"
username = "admin"
password = "admin"

sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)
END

echo "=====Environment Setting Finish.====="
