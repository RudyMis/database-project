<!-- original from https://v3.vuejs.org/examples/grid-component.html -->
<template>
  <table>
    <thead>
      <tr>
        <th v-for="key in columns" @click="sortBy(key)" :class="{ active: sortKey == key }">
          {{ key }}
          <span class="arrow" :class="sortOrders[key] > 0 ? 'asc' : 'dsc'" />
        </th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="entry in filteredRows">
        <td v-for="key in columns" :id="key">
          <input @change="updateDatabase($event, entry, key)" 
            v-if="entry.edit == key" 
            @blur="entry.edit=false; $emit('update')"
            @keyup.enter="entry.edit=false; $emit('update')"
            @keyup.esc="entry.edit=false;"
            v-focus>
          <div v-else-if="key.length != 3 || key == 'sum'">
            {{ entry[key] }}
          </div>
          <div v-else @click="entry.edit=key;">
            {{ entry[key] }}
            <div 
              id=warning
              title="demand exceeds production"
              v-if="entry['fulfillable'] == key">
              ⚠️
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

export default {
  name: 'Grid',
  props: {
    columns: Array,
    gridRows: Array,
  },
  data() {
    const sortOrders = {};
    this.columns.forEach(function(key) {
      sortOrders[key] = 1;
    });
    return {
      sortKey: '',
      sortOrders,
      helper: ''
    }
  },
  computed: {
    filteredRows() {
      const sortKey = this.sortKey
      const order = this.sortOrders[sortKey] || 1
      let gridRows = this.gridRows
      if (sortKey) {
        gridRows = gridRows.slice().sort(function(a, b) {
          a = a[sortKey]
          b = b[sortKey]
          return (a === b ? 0 : a > b ? 1 : -1) * order
        })
      }
      return gridRows
    },
    sortOrders() {
      const columnSortOrders = {};
      this.columns.forEach(function(key) {
        columnSortOrders[key] = 1
      })

      return columnSortOrders
    }
  },
  methods: {
    sortBy(key) {
      this.sortKey = key
      this.sortOrders[key] = this.sortOrders[key] * -1
    },
    updateDatabase(event, entry, key) {
      let value = event.target.value.trim();
      this.$emit('change', value, entry, key);
    }
  },
  directives: {
    focus: {
      inserted (el) {
        el.focus()
      }
    }
  }
};
</script>

<style>

table {
 font-family: Helvetica Neue, Arial, sans-serif;
 font-size: 14px;
 border:0 solid #42b983;
 border-radius:3px;
 background-color:#fff;

}

#warning {
  float: right;
}

th {
 background-color:#42b983;
 color:hsla(0,0%,100%,.66);
 cursor:pointer;
 -webkit-user-select:none;
 -moz-user-select:none;
 -ms-user-select:none;
 user-select:none
}

td {
 background-color: #f9f9f9;
}

td,
th {
 padding:4px 6px 3px 6px;
 text-align:center;
 
}

th.active {
 color:#fff
}

th.active .arrow {
 opacity:1
}

.arrow {
  display:inline-block;
  vertical-align:middle;
  width:0;
  height:0;
  margin-left:5px;
  opacity:.66
}

.arrow.asc {
  border-bottom:4px solid #fff
}

.arrow.asc,
.arrow.dsc {
  border-left:4px solid transparent;
  border-right:4px solid transparent
}

.arrow.dsc {
  border-top:4px solid #fff
}

#item_info {
  min-width:120px
}

#item_id {
  min-width: 80px
}

#jan,
#mar,
#may,
#jul,
#sep,
#nov {
  background-color:#efefef
}

#sum {
  background-color:#e0e0e0
}

</style>
