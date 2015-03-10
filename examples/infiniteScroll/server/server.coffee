N_USERS = 100
N_POSTS = 1000

Meteor.startup ->
  if Meteor.users.find().count() is 0
    console.log "creating fake users and fake posts"

    for i in [0...N_USERS]
      u = Fake.user()
      Accounts.createUser 
        username: u.fullname.replace(/\s+/g, '') + i.toString()
        email: u.email
        password: "123456"

    for j in [0...N_POSTS]
      user = _.sample(Meteor.users.find().fetch())
      Posts.insert
        title: Fake.sentence(3)
        userId: user._id
        date: Date.now()

Meteor.publishComposite 'posts', (limit) ->

  return {
    find: ->
      Posts.find({}, {sort: {name: 1, date: -1}, limit: limit}  )
    children: [
      { 
        find: (post) ->
            Meteor.users.find({_id: post.userId}, {fields: {_id: 1, username: 1}})
      }
    ]
  }
