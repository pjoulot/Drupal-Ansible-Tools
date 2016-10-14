<?php

/**
* Trusted host configuration.
*/
$settings['trusted_host_patterns'] = array(
  '^{{ project }}\.lxc$',
  'localhost'
);

$databases['default']['default'] = array (
  'database' => {{ project }},
  'username' => {{ project }},
  'password' => {{ project }},
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);

$settings['install_profile'] = {{ drupal_profile }};



