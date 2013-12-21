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

echo
echo "the box is almost ready to go. execute these commands:"
echo
echo "$ rbenv install 2.0.0-p353"
echo "$ rbenv global 2.0.0-p353"
echo "$ gem install bundler"
echo "$ rbenv rehash"
echo "$ cd /vagrant"
echo "$ bundle install"
echo "$ gem build ./terminal_player.gemspec"
echo "$ gem install ./terminal_player-0.0.5.gem"
echo "$ rbenv rehash"
echo
echo "and you're good to go..."

