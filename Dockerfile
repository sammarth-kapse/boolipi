# Start from golang base image
FROM golang:alpine as builder

# ENV GO111MODULE=on

# Add Maintainer info
LABEL maintainer="Amrendra Singh <theamrendrasingh@gmail.com>"

# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git 

# Set the current working directory inside the container 
WORKDIR /boolipi

# Copy go mod and sum files 
COPY ./src .

# Download all dependencies. Dependencies will be cached if the go.mod and the go.sum files are not changed 
RUN go mod download 

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# # Start a new stage from scratch
FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN apk add curl

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage. Observe we also copied the .env file
COPY --from=builder /boolipi/main .
# COPY --from=builder /boolipi/.env .       

# Expose port 8080 to the outside world
EXPOSE 8080

#Command to run the executable
CMD ["./main"]