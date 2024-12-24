ARG PYTHON_VERSION
ARG JAVA_VERSION


FROM eclipse-temurin:${JAVA_VERSION}-jre as java-jre

FROM python:${PYTHON_VERSION}-slim AS base

ARG SPARK_VERSION
ARG PYTHON_MAJOR_MINOR_VERSION
ARG SCALA_VERSION
ARG DELTA_VERSION
ARG HADOOP_VERSION

# Set environment variables
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="${JAVA_HOME}/bin:${PATH}" \
    PIPENV_VENV_IN_PROJECT=1 \
    SPARK_HOME="/opt/spark" \
    SPARK_CONF_DIR="${SPARK_HOME}/conf" \
    SPARK_EXTRA_CLASSPATH="${SPARK_HOME}/tmp/ivy2/jars/*" \
    SPARK_CLASSPATH="${SPARK_HOME}/jars/*" \
    SPARK_PUBLIC_DNS=localhost \
    PATH="${SPARK_HOME}/bin/:${PATH}:${SPARK_HOME}/tmp/ivy2/jars"

# Copy requirements and install dependencies
COPY requirements.txt /tmp/requirements.txt
RUN apt-get update && apt-get install -y wget curl procps \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && pip install --no-cache-dir pyspark==$SPARK_VERSION \
    && pip cache purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \ 
    && mkdir $SPARK_HOME

# Conditional URL construction based on Scala and Spark versions
RUN if [ "$SCALA_VERSION" = "2.13" ] && [ "$(printf '%s\n' "$SPARK_VERSION" "4.0.0" | sort -V | head -n1)" != "4.0.0" ]; then \
        wget --verbose "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$(echo $HADOOP_VERSION | cut -d '.' -f1)-scala$SCALA_VERSION.tgz" -O /tmp/spark.tgz; \
    else \
        wget --verbose "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$(echo $HADOOP_VERSION | cut -d '.' -f1).tgz" -O /tmp/spark.tgz; \
    fi && \
    tar -xf /tmp/spark.tgz -C $SPARK_HOME --strip-components=1 && \
    rm /tmp/spark.tgz && \
    rm -r $SPARK_HOME/R $SPARK_HOME/data $SPARK_HOME/examples $SPARK_HOME/kubernetes $SPARK_HOME/licenses $SPARK_HOME/sbin $SPARK_HOME/yarn

# Copy the Java Runtime Environment (JRE) from the eclipse-temurin image
COPY --from=java-jre $JAVA_HOME $JAVA_HOME

# Download the latest release of kubectl and make it executable
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Download Bouncy Castle libraries
RUN curl https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15to18/1.79/bcprov-jdk15to18-1.79.jar --output /opt/spark/jars/bcprov-jdk15to18-1.79.jar \
    && curl https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-jdk15to18/1.79/bcpkix-jdk15to18-1.79.jar --output /opt/spark/jars/bcpkix-jdk15to18-1.79.jar

# Set the entrypoint to keep the container running indefinitely
ENTRYPOINT ["sleep", "infinity"]