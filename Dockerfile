# 1. Derleme aşaması (Builder)
FROM ubuntu:22.04 AS builder

# Gerekli bağımlılıkları yükle
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

# Kaynak kodunu klonla ve derle
WORKDIR /usr/src
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git
WORKDIR /usr/src/telegram-bot-api/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target install

# ==============================================

# 2. Çalıştırma aşaması (Runtime)
FROM ubuntu:22.04

# Sadece çalışma zamanı için gerekli kütüphaneleri yükle
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Derlenmiş binary'yi builder aşamasından kopyala
COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

# Kullanıcı oluştur (güvenlik)
RUN useradd -m -s /bin/bash botuser
USER botuser
WORKDIR /home/botuser

# !! DEĞİŞİKLİK BURADA !! 
# Environment variable'ları çalışma anında doğrudan komuta yazalım.
# Kendi API_ID ve API_HASH'inizi buraya yazın.
CMD ["telegram-bot-api", "--api-id=33757614", "--api-hash=14d38ae49320c5206cc498a06947dd27", "--local", "--http-port=8081", "--http-ip-address=0.0.0.0"]
