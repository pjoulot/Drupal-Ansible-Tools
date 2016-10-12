<?php
/**
 * @file
 * Drush aliases configuration file.
 */

$aliases['dev'] = array(
  'root' => '/var/www/{{ project }}/web',
  'uri'  => '{{ project }}.lxc',
);
