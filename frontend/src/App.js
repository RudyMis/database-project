import SelectFromTable from "./components/SelectFromTable.vue"
import Grid from "./components/Grid.vue"
import Chart from "./components/Chart.js"

export default {
  name: 'App',
  data: function() {
    return {
      columns: ['item_id','item_info','country',
        'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec','sum'],
      rows: [],
      demand_id: '',
      demand: '',
      country: '',
      product: '',

      where_req: '',
      
      demandSum: [],
      productionSum: [],
      budgetSum: [],

      chartReady: 0,
    }
  },
  methods: {
    query(table, where_req) {
      let query_string = "http://" + process.env.VUE_APP_BACKEND_HOSTNAME + "/v1/data?table=" + table + where_req;
      return this.$http.get(query_string);
    },
     
    updateTable() {
      if (this.demand_id === '') return;
      this.where_req = this.concatForWhere([this.demand, this.country, this.product])
      this.rows = [];
      this.createChart()
        .then(_ => this.query('demand', this.where_req).then(res => { 
        res.body.forEach(item => {
          this.rows.push(this.mapValues(item));
        });
      }));
    },
    
    async createChart() {
      this.chartReady = 0;
      this.query(
        'demand',
        '&sum' + this.concatForWhere([this.demand, this.country, this.product]))
        .then(res => {
          this.demandSum = res.body.values;
          this.chartReady += 1;
        });
      this.query(
        'budget',
        '&sum' + this.concatForWhere([this.country, this.product]) + this.getYear())
        .then(res => {
          this.budgetSum = res.body.values;
          this.chartReady += 1;
        });
      this.query(
        'production',
        '&sum' + this.concatForWhere([this.country, this.product]) + this.getYear())
        .then(res => {
          this.productionSum = res.body.values;
          this.chartReady += 1;
        });
    },

    // Helper functions
    concatForWhere(arr) {
      arr = arr.filter(elem => elem.length > 0);
      if (arr.length == 0) {
        return "";
      } else {
        return "&where_requirements." + arr.join("&where_requirements."); 
      }
    },
    getYear() {
      if (this.demand_id === '')  return '';
      return "&where_requirements.year(month)=20" + this.demand_id.split(' ')[0];
    },
    mapValues(row) {
      const months = [
        'jan',
        'feb',
        'mar',
        'apr',
        'may',
        'jun',
        'jul', 
        'aug',
        'sep',
        'oct',
        'nov',
        'dec',
        'all'];
      for (let i = 0; i < months.length; i++) {
        Object.defineProperty(row, months[i], { value: row.values[i] });
      }
      row.fulfillable = months[row.fulfillable];
      row.edit = 'false';
      delete row.values;
      return row;
    },

    // Emit recivers
    async updateDatabase(value, entry, month) {
      const post_data = { 
        
          demand_id: encodeURIComponent(this.demand_id),
          item_id: encodeURIComponent(entry['item_id']),
          country: encodeURIComponent(entry['country']),
          month,
          value: parseInt(value)
      };
      let post_query = "http://" + process.env.VUE_APP_BACKEND_HOSTNAME + "/v1/update";
      await this.$http.post(post_query, post_data);
      this.updateTable();
    },
    setDemandId(val) {
      this.demand_id = val;
    }
  },
  components: {
    SelectFromTable,
    Chart,
    Grid
  }
};

