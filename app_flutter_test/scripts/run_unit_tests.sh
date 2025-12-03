export PATH="$PATH:`pwd`/flutter/bin"
if [ ! -d "flutter" ]; then
  echo "Flutter not found, installing..."
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
  git clone https://github.com/flutter/flutter.git -b stable

  export PATH="$PATH:`pwd`/flutter/bin"
fi

flutter doctor

flutter test test/unit/custom/custom_test.dart