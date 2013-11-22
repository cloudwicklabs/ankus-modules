class java7::params {
  $java_version = $::hostname ? {
      default => "1.7.0_25",
  }
  $java_base = $::hostname ? {
      default => "/opt/java7",
  }
}
