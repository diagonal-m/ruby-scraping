FROM ruby:2.6

# デフォルトの locale `C` を `C.UTF-8` に変更する
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# タイムゾーンを日本時間に変更
ENV TZ Asia/Tokyo

# /tmpにコピー
COPY . /tmp

# 相対パスの基準ディレクトリ
WORKDIR /tmp

RUN apt-get update && apt-get install -y vim

RUN gem install nokogiri