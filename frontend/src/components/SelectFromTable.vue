<template>
  <div class="select-dropdown">
    <select v-model="selected" @change="concatSelected($event)">
      <option value="" selected>{{ table_name }}: None</option>
      <optgroup v-for="category in table" v-bind:label="category.name">
        <option v-for="option in category.values">
          {{ option }}
        </option>
      </optgroup>
    </select>
  </div>
</template>

<script>
export default {
  name: 'SelectFromTable',
  model: {
    prop: 'concat',
    event: 'change'
  },
  props: {
    table_name: {
      type: String,
      required: true,
    },
    column: { 
      type: String,
      default: "",
    },
    where_req: {
      type: String,
      default: "",
    }
  },
  emits: ['demand'],
  data: function() {
    return {
      table: [],
      selected: '',
      concat: ''
    }
  },
  methods: {
    concatSelected(event) {
      // https://stackoverflow.com/a/58311873
      // 1. Get the selected index
      const index = event.target.selectedIndex;

      // 2. Find the selected option
      const option = event.target.options[index];

      // 3. Select the parent element (optgroup) for the selected option
      const optgroup = option.parentElement;

      // 4. Finally, get the label (group)
      const group = optgroup.getAttribute('label');
      if (this.selected !== '') {
        this.concat = group + "=" + encodeURIComponent(this.selected);
      } else {
        this.concat = '';
      }
      this.$emit('demand', this.selected);
      this.$emit('change', this.concat);
    },
    cutWhereReq() {
      let arr = this.where_req.split("&");
      arr = arr.filter(element => !element.includes(this.concat) || this.concat === '');
      return arr.join("&");
    },
    updateTable() {
      
      this.$http.get("http://" + process.env.VUE_APP_BACKEND_HOSTNAME + "/v1/values/" + this.table_name + "?" + this.cutWhereReq())
        .then(res => {
          if (this.column !== "") {
            let column = this.column;
            this.table = res.body.filter(function (el) {
              return el.name === column;
            });
          } else {
            this.table = res.body;
          }
      });

    }
  },
  watch: {
    "where_req": function(val, oldVal) {
      this.updateTable();
    }
  },
  created() {
    this.updateTable();
  }
};
</script>

<style>

.select-dropdown {
  margin-right: 10px;
	position: relative;
	background-color: #f9f9f9; 
}
.select-dropdown select {
	font-size: 1rem;
	font-weight: normal;
	max-width: 100%;
	padding: 8px 24px 8px 10px;
	border: none;
	background-color: transparent;
		-webkit-appearance: none;
		-moz-appearance: none;
	appearance: none;
}
.select-dropdown select:active, .select-dropdown select:focus {
	outline: none;
	box-shadow: none;
}
.select-dropdown:after {
	content: "";
	position: absolute;
	top: 50%;
	right: 8px;
	width: 0;
	height: 0;
	margin-top: -2px;
	border-top: 5px solid #aaa;
	border-right: 5px solid transparent;
	border-left: 5px solid transparent;
}

</style>
