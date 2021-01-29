<h1 class="center"><a href="https://github.com/thewhiterabbit/Deploy_Saleor">Deploy Saleor</a></h1>
<h2 class="center">A bash script for Production Deployment of <a href="https://github.com/mirumee/saleor">Saleor</a></h2>
<hr>
<h3>Description</h2>
<p>This script set intends to install and setup specific dependancies, Saleor, and Saleor Dashboard for a production environment. It is assumed that you have already installed Nginx, PHP 7.4, and have some general understanding of the settings.py file and how to setup email outside of this script. Email setup will be added in future versions of this script. This is the initial public release for alpha testing on Ubuntu 20.04 systems.</p>

<h3>Contribution</h3>
<p>If you want to contribute to this script set, please clone the repository, make your desired upgrades, updates, or fixes, and submit a pull request with documentatiomn of your upgrades, updates, or fixes. Your contributions will be added to a list appended to this readme file and are very much appreciated.</p>

<h3>Disclaimer</h3>
<p>Although I have done my best to be as thourogh as I am capable of, there may be some overlooked concerns for security invloving the virtual environment
, Emperor, or other aspects that are currently outside my scope of knowledge. This script set is provided without gurarantee.</p>
<hr>
<h3>Install & Dependancy List</h3>
<h4>deploy-saleor.sh installs...</h4>
<ul>
    <li>
        <a href="https://github.com/mirumee/saleor">Saleor</a>
    </li>
    <li>build-essential</li>
    <li>python3-dev</li>
    <li>python3-pip</li>
    <li>python3-cffi</li>
    <li>python3-venv</li>
    <li>gcc</li>
    <li>libcairo2</li>
    <li>libpango-1.0-0</li>
    <li>libpangocairo-1.0-0</li>
    <li>libgdk-pixbuf2.0-0</li>
    <li>libffi-dev</li>
    <li>shared-mime-info</li>
    <li>nodejs</li>
    <li>npm</li>
    <li>postgresql</li>
    <li>postgresql-contrib</li>
</ul>
<h4>deploy-dashboard.sh installs...</h4>
<ul>
    <li>
        <a href="https://github.com/mirumee/saleor-dashboard">Saleor Dashboard</a>
    </li>
</ul>
<hr>
<h3>Awesome Contributors</h3>
<ul>
    <li>
        <p>
            <a href="https://github.com/mirumee">Saleor Team</a> - For making the <a href="https://github.com/mirumee/saleor-platform">Saleor Platform</a>, and inspiring this repository.
        </p>
    </li>
</ul>