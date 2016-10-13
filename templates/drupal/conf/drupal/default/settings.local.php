<?php

/**
* Trusted host configuration.
*/
$settings['trusted_host_patterns'] = array(
  '^{{ project }}\.lxc$',
  'localhost'
);

$settings['hash_salt'] = {{ project }};

$databases['default']['default'] = array (
  'database' => {{ project }},
  'username' => {{ project }},
  'password' => {{ project }},
  'prefix' => '',
  'host' => 'localhost',
  'port' => '',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);

$settings['install_profile'] = {{ drupal_profile }};



