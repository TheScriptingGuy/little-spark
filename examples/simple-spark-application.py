from pyspark.sql import SparkSession

spark_version = "3.5.1"
java_version = "17"

# Define the Kubernetes master URL
k8s_master_url = "k8s://https://localhost:6443"

# Define the Spark image to use
spark_image = f"apache/spark:{spark_version}-java{java_version}-python3"

# Path to the self-signed certificate inside the container
ca_cert_file = "/usr/local/share/ca-certificates/ca.crt"
client_key_file = "/usr/local/share/ca-certificates/tls.crt"
client_cert_file = "/usr/local/share/ca-certificates/tls.key"
    
# Create the SparkSession
spark = (SparkSession.builder 
    .appName("PySpark on Kubernetes") 
    .master(k8s_master_url) 
    .config("spark.kubernetes.container.image", spark_image) 
    .config("spark.kubernetes.namespace", "spark") 
    .config("spark.executor.instances", "2")
    .getOrCreate())

# Example DataFrame operation
data = [("Alice", 34), ("Bob", 45), ("Cathy", 29)]
columns = ["Name", "Age"]
df = spark.createDataFrame(data, columns)
df.show()

# Stop the SparkSession
spark.stop()