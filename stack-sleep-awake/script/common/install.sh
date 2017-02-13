install_apex ()
{
  if type bundle > /dev/null
  then
    echo ""
    echo " → Upgrading Apex"
    echo ""
    apex upgrade
    echo ""
    echo "  ✔ Apex successfully installed"
  else
    echo ""
    echo " → Installing Apex"
    echo ""
    curl -s https://raw.githubusercontent.com/apex/apex/master/install.sh | sh > /dev/null
    echo ""
    echo "  ✔ Apex successfully installed"
  fi
}

install_nvm ()
{
  echo ""
  echo " → Installing nvm"
  echo ""
  if [ -f ~/.nvm/nvm.sh ]
  then
    echo "  ✔ nvm is already installed"
  else
    curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.4/install.sh | bash > /dev/null
    echo ""
    echo "  ✔ nvm successfully installed"
  fi
  source ~/.nvm/nvm.sh
}

install_node ()
{
  echo ""
  echo " → Installing node v'$(cat .nvmrc)'"
  echo ""
  nvm install
  echo ""
  echo "  ✔ node v'$(cat .nvmrc)' successfully installed"
}

install_npm_packages ()
{
  FILES=functions/*
  echo ""
  echo " → Installing npm packages"
  echo ""
  source ~/.nvm/nvm.sh

  for dir in $FILES
  do
    IFS='/' read -ra NAMES <<< "$dir"
    cd "functions/${NAMES[1]}"
    echo "****************************************"
    echo "Installing dependencies for ${NAMES[1]}"
    echo "****************************************"
    nvm exec npm install
    cd ../..
  done
  echo "  ✔ npm packages successfully installed"
}
