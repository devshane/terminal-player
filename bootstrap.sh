apt-get update

apt-get install -y build-essential checkinstall
apt-get install -y git
apt-get install -y libopenal1 libopenal-dev
apt-get install -y mplayer

# rbenv

git clone https://github.com/sstephenson/rbenv.git ~vagrant/.rbenv
echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~vagrant/.bashrc
echo 'eval \"$(rbenv init -)\"' >> ~vagrant/.bashrc

mkdir ~vagrant/.rbenv/plugins
git clone https://github.com/sstephenson/ruby-build.git ~vagrant/.rbenv/plugins/ruby-build

chown -R vagrant:vagrant ~vagrant

# install a ruby
echo
echo "ok, it's up to you to install a ruby:"
echo "$ rbenv install 1.9.3-p484"
echo "$ rbenv install 2.0.0-p353"
echo
echo "then install bundler:"
echo "$ gem install bundler"
echo

# gem install bundler

