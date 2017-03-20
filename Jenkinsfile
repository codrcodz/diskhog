pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh "mkdir ./sql"
                sh "mkdir ./txt"
                sh "fallocate -l 250M ./sql/250M.sql"
                sh "fallocate -l 250M ./txt/250M.txt"
                sh "fallocate -l 50M ./sql/50M.sql"
                sh "fallocate -l 50M ./txt/50M.txt"
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                sh "./diskhog.sh --fastest 50"
                sh "./diskhog.sh --faster 50"
                sh "./diskhog.sh --fast 250"
                sh "./diskhog.sh --slow 250"
                sh bashtest ./test/fastest_test.bashtest
                sh bashtest ./test/faster_test.bashtest
                sh bashtest ./test/fast_test.bashtest
                sh bashtest ./test/slow_test.bashtest
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
