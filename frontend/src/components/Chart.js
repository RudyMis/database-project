import { Bar } from 'vue-chartjs'

export default {
  extends: Bar,
  data: function() {
    return {
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
      },
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    }
  },
  props: {
    budget: {
      type: Array,
      default: function() {return [0,0,0,0,0,0,0,0,0,0,0,0]},
    },
    production: {
      type: Array,
      default: function() {return [0,0,0,0,0,0,0,0,0,0,0,0]},
    },
    demand: {
      type: Array,
      default: function() {return [0,0,0,0,0,0,0,0,0,0,0,0]},
    },
  },

  mounted () {
    this.renderChart(
      {
        labels: this.labels,
        datasets: [
          {
            type: 'bar',
            label: 'budget',
            data: this.budget,
            backgroundColor: '#85E37880',
          },
          {
            type: 'bar',
            label: 'demand',
            data: this.demand,
            backgroundColor: '#3D59DE80',
          },
          {
            type: 'line',
            label: 'production',
            data: this.production,
            backgroundColor: '#FFFFFF00',
            borderColor: '#FFA427',
            tension: 0.1,
          }
        ]
      },
      this.options
    )
  }
}
