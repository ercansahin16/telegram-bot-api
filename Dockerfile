# Bunu yapmak için resmi bir Ubuntu imajı kullanıyoruz
FROM ubuntu:22.04

# Gerekli bağımlılıkları yüklüyoruz
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    cmake \
    g++ \
    make \
    libssl-dev \
    zlib1g-dev \
    gperf \
    && rm -rf /var/lib/apt/lists/*

# Telegram Bot API kaynak kodunu klonluyoruz
WORKDIR /usr/src
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git

# Kaynak kodu derliyoruz
WORKDIR /usr/src/telegram-bot-api/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target install

# Çalışma zamanı için bir kullanıcı oluşturuyoruz (güvenlik için)
RUN useradd -m -s /bin/bash botuser

# Derlenmiş binary'nin bulunduğu dizini PATH'e ekliyoruz
ENV PATH="/usr/local/bin:${PATH}"

# Çalışma dizinini ayarlıyoruz
WORKDIR /home/botuser
USER botuser

# Bot API sunucusunun varsayılan portunu dışarıya açıyoruz
EXPOSE 8081

# Sunucuyu başlatmak için hazırız
ENTRYPOINT ["telegram-bot-api"]
# Varsayılan ayarları belirtiyoruz; bu ayarlar çalıştırılırken ezilebilir
CMD ["--help"]
