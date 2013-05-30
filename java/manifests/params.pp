class java::params {
  $java_version = $::hostname ? {
      default	=> "1.6.0_31",
  }
  $java_base = $::hostname ? {
      default     => "/opt/java",
  }
}
