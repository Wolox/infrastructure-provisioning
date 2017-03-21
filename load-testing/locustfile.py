import threading, csv, base64, json, random, uuid, boto3 #pip install boto 3
from locust import HttpLocust, TaskSet, task #pip install locust
from jose import jwt #pip install python-jose

usersDict = None
usersDictFilled = False
lock = threading.Lock()

#Developer Credentials are mandatory
#Example done with Nubi
userPoolId='us-east-1_abSciuce3'
clientId='4nj1kecn2bfobfejgvbkfan7lv'

class UserBehavior(TaskSet):
    def on_start(self):
        #on_start is called when a Locust starts before any task is scheduled
        if usersDictFilled is False:
          self.login()

    def login(self):
        global usersDict
        global usersDictFilled
        global lock
        global clientId
        global userPoolId
        lock.acquire()
        if usersDict is None:
          csvfile = open('users.csv')
          usersCsv = csv.DictReader(csvfile)
          client = boto3.client('cognito-idp')
          usersDict = {}
          for row in usersCsv:
            res = client.admin_initiate_auth(
              UserPoolId=userPoolId,
              AuthFlow='ADMIN_NO_SRP_AUTH',
              AuthParameters={
                  'USERNAME': row['username'],
                  'PASSWORD': row['password']
              },
              ClientId=clientId
            )
            token = str(res['AuthenticationResult']['IdToken'])
            base = base64.b64decode(token.split(".", 2)[1] + "==")
            base = json.loads(base)
            usersDict[base['sub']] = token
            self.client.post("/new_session", headers = {'authorization':token})
          usersDictFilled = True
        lock.release()
    
    @task(2)
    def signup(self):
      with open('signup.json') as data_file:    
          data = json.load(data_file)
      username = "lt+" + str(uuid.uuid4()).replace("-","") + "@wolox.com.ar"
      data['Username'] = username
      data['UserAttributes'][0]['Value'] = username
      client = boto3.client('cognito-idp')
      res = client.sign_up(**data)
      print(res)

    @task(5)
    def get_notifications(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userToken = usersDict.values()[userIndex]
        res = self.client.get("/notifications/", headers = {'authorization':userToken})

    @task(1)
    def get_user_profile(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userToken = usersDict.values()[userIndex]
        userSub = usersDict.keys()[userIndex]
        res = self.client.get("/users/" + userSub, headers = {'authorization':userToken})

    @task(1)
    def update_user_profile(self):
        global usersDict
        with open('user_update.json') as data_file:    
            data = json.load(data_file)
        userIndex = random.randint(0, len(usersDict) - 1)
        userToken = usersDict.values()[userIndex]
        userSub = usersDict.keys()[userIndex]
        data['id'] = userSub
        data['user']['id'] = userSub
        res = self.client.put("/users/" + userSub, headers = {'authorization':userToken}, data = data)

    @task(1)
    def get_user_paypal_balance(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userToken = usersDict.values()[userIndex]
        res = self.client.get("/paypal/balance", headers = {'authorization':userToken})

    @task(1)
    def get_transactions_in_progress_amount(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userSub = usersDict.keys()[userIndex]
        userToken = usersDict.values()[userIndex]
        res = self.client.get("/transactions/users/" + userSub + "/transactionInProgressAmount", headers = {'authorization':userToken})

    @task(1)
    def get_transactions_in_progress(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userSub = usersDict.keys()[userIndex]
        userToken = usersDict.values()[userIndex]
        res = self.client.get("/transactions/users/" + userSub + "/transactionsInProgress?offset=0&limit=6", headers = {'authorization':userToken})

    @task(1)
    def get_transactions_completed(self):
        global usersDict
        userIndex = random.randint(0, len(usersDict) - 1)
        userSub = usersDict.keys()[userIndex]
        userToken = usersDict.values()[userIndex]
        res = self.client.get("/transactions/users/" + userSub + "/transactionsCompleted?offset=0&limit=6", headers = {'authorization':userToken})

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 2000
    max_wait = 5000