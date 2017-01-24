module Core
  class SecurityGroup
    attr_reader :parameters, :client

    def initialize(parameters)
      @parameters = parameters
      @client = init_client
    end

    def create_security_group(service)
      return fetch_security_group(service) if security_group_exists?(service)
      client.create_security_group({
        dry_run: false,
        group_name: "#{parameters.identifier}-#{service}",
        description: "#{parameters.identifier}-#{service}"
      })
    end

    def allow_access(sg_id, source_group, from_port, to_port, protocol)
      client.authorize_security_group_ingress(
        group_id: sg_id, ip_permissions: [
          {
            ip_protocol: protocol, from_port: from_port, to_port: to_port, user_id_group_pairs: [
              { group_name: source_group }
            ]
          }
        ]
      )
    end

    private

    def fetch_security_group(service)
      resp = client.describe_security_groups(group_names: ["#{parameters.identifier}-#{service}"])
      resp.security_groups.first
    rescue Aws::EC2::Errors::InvalidGroupNotFound
    end

    def security_group_exists?(service)
      fetch_security_group(service) != nil
    end

    def init_client
      Aws::EC2::Client.new(
        region: parameters.region,
        profile: parameters.profile
      )
    end
  end
end
