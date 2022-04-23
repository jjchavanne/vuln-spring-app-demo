FROM maven:3.8.5-jdk-11 as build

# Add a new user "john" with user id 8877
# RUN useradd -u 8877 john
# Change to non-root privilege
# USER john

ARG USERNAME=john
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME |
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

WORKDIR /app
COPY app /app
RUN mvn clean package

FROM tomcat:10-jdk11-openjdk-slim
COPY flag /flag
EXPOSE 8080
COPY --from=build /app/target/helloworld.war $CATALINA_HOME/webapps
