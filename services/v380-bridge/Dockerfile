FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG V380_DECODER_REPO=https://github.com/PyanSofyan/V380Decoder.git
ARG V380_DECODER_COMMIT=89588225420a882e800f31535a490741cf2cbd5a
WORKDIR /src
RUN git clone --filter=blob:none "$V380_DECODER_REPO" . \
    && git fetch origin pull/17/head \
    && git checkout --detach "$V380_DECODER_COMMIT"
RUN dotnet publish V380Decoder.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
USER app
EXPOSE 8554 8080
ENTRYPOINT ["./V380Decoder"]
