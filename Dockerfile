FROM ruby:2.2
RUN apt-get update \
    && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client emacs
RUN npm install -g phantomjs
RUN mkdir /enterprise_cms
RUN mkdir /tmp/gems

# WORKDIR /tmp/gems
# COPY Gemfile.app Gemfile.app
# RUN bundle install --gemfile=Gemfile.app

ADD . /enterprise_cms

WORKDIR /enterprise_cms

# VOLUME .:/myapp

ENV RAILS_ENV=production
ENV RAILS_PORT=3009
ENV RAILS_HOME=/myapp
ENV SECRET_KEY_BASE=c733aabc894e4464031641d68f9c2066df51d177d793f462892b20ec8c50df7c06aa30fdd1153c19e6487684254fface62f09af847ad4cfb85c537d84e3e3a38

RUN bundle install

# RUN bundle install --gemfile=Gemfile.components
# RUN mv Gemfile.components.lock Gemfile.lock

# bundle install needs to be after adding rails dir since Gemfile refers to engines in components dir of app.



EXPOSE 3009

# You have to run this CMD with 0.0.0.0 IP address for port mapping to work in Docker container. Very strange.
# NOTE: the rake commands are being run here before starting rails to setup database. There has to be a better way. Need to investigate.
CMD ./script/clear_pids.sh \
    && rake assets:precompile \
    && rails server -p 3009 -e production -b 0.0.0.0











