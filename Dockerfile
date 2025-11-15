FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get

COPY . .

RUN flutter pub get

# Позволяет переопределить base href при сборке (по умолчанию '/')
ARG BASE_HREF=/
ENV BASE_HREF=${BASE_HREF}

# Собираем веб-приложение для продакшена
RUN flutter build web --release --base-href ${BASE_HREF}

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
