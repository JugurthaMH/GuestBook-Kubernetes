FROM golang:1.27.1 AS builder

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY main.go .
RUN CGO_ENABLED=0 go build -o guestbook main.go
FROM scratch
COPY --from=builder /app/guestbook /guestbook
COPY ./public public

CMD ["/guestbook"]