from pyspark.sql import SparkSession

spark_version = "3.5.1"
java_version = "17"

# Define the Kubernetes master URL
k8s_master_url = "k8s://http://kubernetes.default.svc.cluster.local:443"

# Define the Spark image to use
spark_image = f"apache/spark:{spark_version}-java{java_version}-python3"
    
# Create the SparkSession
spark = (SparkSession.builder 
    .appName("PySpark on Kubernetes") 
    .master(k8s_master_url) 
    .config("spark.kubernetes.container.image", spark_image) 
    .config("spark.kubernetes.namespace", "spark") 
    .config("spark.executor.instances", "1")
    .getOrCreate())

# Example DataFrame operation
data = [("Alice", 34), ("Bob", 45), ("Cathy", 29)]
columns = ["Name", "Age"]
df = spark.createDataFrame(data, columns)
df.show()

# Stop the SparkSession
spark.stop()