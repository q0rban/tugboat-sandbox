const {createServer} = require('@lhci/server');

console.log('Starting server...');
createServer({
  port: 3000,
  storage: {
    storageMethod: 'sql',
    sqlDialect: 'sqlite',
    sqlDatabasePath: __dirname + '/database.sql',
  },
}).then(({port}) => console.log('LHCI listening on port', port));
