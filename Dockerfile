FROM binaryphile/ruby:2.0.0-p247
ADD . /code
WORKDIR /code
RUN bundle install
EXPOSE 4567
CMD bundle exec ruby app.rb
