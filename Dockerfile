FROM python:3.12-alpine

# Set build arguments
ARG RELEASE_VERSION
ENV RELEASE_VERSION=${RELEASE_VERSION}

# Create User
ARG UID=1000
ARG GID=1000
RUN addgroup -g $GID general_user && \
    adduser -D -u $UID -G general_user -s /bin/sh general_user

# Install ffmpeg and cron
RUN apk update && apk add --no-cache ffmpeg && apk add --no-cache curl bash busybox-suid

# Add the update script to the container
COPY update_yt_dlp.sh /usr/local/bin/update_yt_dlp.sh
RUN chmod +x /usr/local/bin/update_yt_dlp.sh


# Create cron job to run the script once a day
RUN echo "0 0 * * * /usr/local/bin/update_yt_dlp.sh > /var/log/cron.log 2>&1" >> /etc/crontabs/root

# Make sure the cron service is started and kept running in the background
RUN chmod 0644 /etc/crontabs/root

# Create directories and set permissions
COPY . /syncify
WORKDIR /syncify
RUN mkdir -p /syncify/downloads
RUN chown -R $UID:$GID /syncify
RUN chmod -R 777 /syncify/downloads

# Install requirements and run code as general_user
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
USER general_user
# Start cron and then your application
CMD /usr/local/bin/update_yt_dlp.sh && crond && gunicorn src.Syncify:app -c gunicorn_config.py