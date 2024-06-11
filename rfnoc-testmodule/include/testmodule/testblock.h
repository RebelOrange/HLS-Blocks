/* -*- c++ -*- */
/* 
 * Copyright 2024 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */


#pragma once

#include <testmodule/api.h>
#include <ettus/rfnoc_block.h>
#include <ettus/rfnoc_graph.h>

namespace gr {
  namespace testmodule {

    /*!
     * \brief <+description of block+>
     * \ingroup testmodule
     *
     */
    class TESTMODULE_API testblock : virtual public gr::ettus::rfnoc_block
    {
     public:
      typedef boost::shared_ptr<testblock> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of testmodule::testblock.
       *
       * To avoid accidental use of raw pointers, testmodule::testblock's
       * constructor is in a private implementation
       * class. testmodule::testblock::make is the public interface for
       * creating new instances.
       */
      static sptr make(
        const gr::ettus::rfnoc_graph::sptr graph,
        const ::uhd::device_addr_t& block_args,
        const int device_select,
        const int instance);
    };
  } // namespace testmodule
} // namespace gr


