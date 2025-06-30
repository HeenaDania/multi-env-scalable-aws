#!/bin/bash
# This script runs when EC2 instances start up
# It installs and configures the web server with your HTML application

yum update -y
yum install -y httpd awscli

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create your HTML application
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Modern Photo Gallery - ${environment}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root {
      --blue1: #4da8da;
      --blue2: #12232e;
      --blue3: #007cc7;
      --white: #f9fafb;
      --card-bg: #fff;
      --text: #22223b;
      --subtext: #4a4e69;
      --shadow: 0 8px 24px rgba(34, 34, 59, 0.08);
      --radius: 18px;
      --accent: #51d0de;
    }
    body {
      margin: 0;
      padding: 0;
      background: var(--white);
      font-family: 'Segoe UI', 'Roboto', Arial, sans-serif;
      color: var(--text);
      min-height: 100vh;
    }
    header {
      background: linear-gradient(135deg, var(--blue1) 0%, var(--blue3) 100%);
      padding: 44px 0 28px 0;
      text-align: center;
      border-bottom-left-radius: 48px;
      border-bottom-right-radius: 48px;
      box-shadow: 0 4px 24px rgba(77, 168, 218, 0.10);
      position: relative;
      z-index: 1;
    }
    header h1 {
      margin: 0;
      font-size: 2.7rem;
      font-weight: bold;
      letter-spacing: 1px;
      color: #fff;
      text-shadow: 0 2px 8px rgba(18,35,46,0.10);
    }
    header p {
      color: #e3f2fd;
      margin-top: 10px;
      font-size: 1.2rem;
      letter-spacing: 0.5px;
    }
    .env-banner {
      background: #ff6b6b;
      color: white;
      text-align: center;
      padding: 10px;
      font-weight: bold;
      text-transform: uppercase;
    }
    .gallery {
      margin: 40px auto 0 auto;
      max-width: 1100px;
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 36px;
      padding: 0 24px 48px 24px;
    }
    .photo-card {
      background: var(--card-bg);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow: hidden;
      transition: transform 0.22s cubic-bezier(.22,1,.36,1), box-shadow 0.18s;
      display: flex;
      flex-direction: column;
      align-items: center;
      cursor: pointer;
      position: relative;
    }
    .photo-card::after {
      content: "";
      display: block;
      position: absolute;
      inset: 0;
      border-radius: var(--radius);
      box-shadow: 0 0 0 0 var(--accent);
      transition: box-shadow 0.2s;
      pointer-events: none;
    }
    .photo-card:hover {
      transform: translateY(-8px) scale(1.04) rotate(-1deg);
      box-shadow: 0 12px 32px rgba(77, 168, 218, 0.17);
      z-index: 2;
    }
    .photo-card:hover::after {
      box-shadow: 0 0 0 4px var(--accent);
    }
    .photo-card img {
      width: 100%;
      height: 220px;
      object-fit: cover;
      display: block;
      border-top-left-radius: var(--radius);
      border-top-right-radius: var(--radius);
      transition: filter 0.18s;
    }
    .photo-card:hover img {
      filter: brightness(1.08) saturate(1.2);
    }
    .photo-card .caption {
      padding: 18px 16px 16px 16px;
      color: var(--subtext);
      font-size: 1.12rem;
      text-align: center;
      background: #f7fafd;
      width: 100%;
      border-bottom-left-radius: var(--radius);
      border-bottom-right-radius: var(--radius);
      transition: background 0.2s;
    }
    .photo-card:hover .caption {
      background: #e3f2fd;
      color: var(--blue2);
    }
    @media (max-width: 700px) {
      header h1 { font-size: 2rem; }
      .gallery { gap: 20px; }
      .photo-card img { height: 140px; }
    }
  </style>
</head>
<body>
  <div class="env-banner">Environment: ${environment}</div>
  <header>
    <h1>Modern Photo Gallery</h1>
    <p>Explore beautiful moments, interact and enjoy the view</p>
  </header>
  <main>
    <div class="gallery">
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80" alt="Mountain Lake">
        <div class="caption">Serene Mountain Lake</div>
      </div>
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80" alt="Forest Path">
        <div class="caption">Sunlit Forest Path</div>
      </div>
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=600&q=80" alt="Desert Dunes">
        <div class="caption">Golden Desert Dunes</div>
      </div>
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80" alt="Ocean Cliff">
        <div class="caption">Majestic Ocean Cliffs</div>
      </div>
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80" alt="Blooming Field">
        <div class="caption">Blooming Flower Field</div>
      </div>
      <div class="photo-card">
        <img src="https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=600&q=80" alt="Snowy Mountains">
        <div class="caption">Snowy Mountain Peaks</div>
      </div>
    </div>
  </main>
</body>
</html>
EOF

# Install and configure CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/httpd/access_log",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/httpd/error_log",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create a simple health check endpoint
echo "OK" > /var/www/html/health.html

# Restart Apache to ensure everything is working
systemctl restart httpd
