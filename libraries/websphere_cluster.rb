#
# Cookbook Name:: websphere
# Resource:: websphere-server
#
# Copyright (C) 2015 J Sainsburys
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'websphere_base'

module WebsphereCookbook
  class WebsphereCluster < WebsphereBase
    require_relative 'helpers'
    include WebsphereHelpers

    resource_name :websphere_cluster
    property :cluster_name, String, name_property: true
    property :prefer_local, [TrueClass, FalseClass], default: true
    property :cluster_type, String, required: true, default: 'APPLICATION_SERVER', regex: /^(APPLICATION_SERVER|PROXY_SERVER)$/

    # creates an empty cluster
    action :create do
      unless cluster_exists?(cluster_name)
        cmd = "AdminClusterManagement.createClusterWithoutMember('#{cluster_name}')"
        wsadmin_exec("wasadmin createClusterWithoutMember #{cluster_name}", cmd)
        save_config
      end
    end

    action :delete do
      delete_cluster(cluster_name) if cluster_exists?(cluster_name)
      save_config
    end

    action :ripple_start do
      cmd = "AdminClusterManagement.rippleStartSingleCluster('#{cluster_name}')"
      wsadmin_exec("wasadmin ripple_restart cluster: #{cluster_name} ", cmd, [0, 103])
    end

    action :start do
      cmd = "AdminClusterManagement.startSingleCluster('#{cluster_name}')"
      wsadmin_exec("wasadmin start cluster: #{cluster_name} ", cmd, [0, 103])
    end

    action :stop do
      cmd = "AdminClusterManagement.stopSingleCluster('#{cluster_name}')"
      wsadmin_exec("wasadmin stop cluster: #{cluster_name} ", cmd, [0, 103])
    end
  end
end
